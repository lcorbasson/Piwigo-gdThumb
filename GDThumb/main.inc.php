<?php
/*
Plugin Name: gdThumb
Version: 1.0.4
Description: Display thumbnails as patchwork
Plugin URI: http://piwigo.org/ext/extension_view.php?eid=771
Author: Serge Dosyukov 
Author URI: http://blog.dragonsoft.us
*/
// Original work by P@t - GTHumb+

global $conf;

if (!defined('PHPWG_ROOT_PATH')) die('Hacking attempt!');

if (mobile_theme()) return;

define('GDTHUMB_PATH' , PHPWG_PLUGINS_PATH . basename(dirname(__FILE__)) . '/');

if (!isset($conf['gdThumb'])):
  include(dirname(__FILE__).'/config_default.inc.php');

  $query = '
INSERT INTO ' . CONFIG_TABLE . ' (param,value,comment)
VALUES ("gdThumb" , "'.addslashes(serialize($config_default)).'" , "GDThumb plugin parameters");';
  pwg_query($query);
  load_conf_from_db();
endif;

$conf['gdThumb'] = unserialize($conf['gdThumb']);

// RV Thumbnails Scroller
if (isset($_GET['rvts'])) {
  $conf['gdThumb']['big_thumb'] = false;
  add_event_handler('loc_end_index_thumbnails', 'process_GDThumb', 50, 2);
}

add_event_handler('init', 'GDThumb_init');
add_event_handler('loc_begin_index', 'GDThumb_index', 60);
add_event_handler('loc_end_index_category_thumbnails', 'GDThumb_process_category', 50, 2);
add_event_handler('get_admin_plugin_menu_links', 'GDThumb_admin_menu');
add_event_handler('loc_end_index', 'GDThumb_remove_thumb_size');

function GDThumb_init() {
  global $conf, $user, $page, $stripped;

  $confTemp = $conf['gdThumb'];
  $user['nb_image_page']    = $confTemp['nb_image_page'];
  $page['nb_image_page']    = $confTemp['nb_image_page'];
  $stripped['maxThumb']     = $confTemp['nb_image_page'];
  $conf['thumb_mode_album'] = $confTemp['thumb_mode_album'];
  $conf['thumb_mode_photo'] = $confTemp['thumb_mode_photo'];
  $conf['thumb_metamode']   = $confTemp['thumb_metamode'];
}

function GDThumb_index() {
  global $template;
  
  $template->set_prefilter('index', 'GDThumb_prefilter');

  add_event_handler('loc_end_index_thumbnails', 'GDThumb_process_thumb', 50, 2);
}

function GDThumb_process_thumb($tpl_vars, $pictures) {
  global $template, $conf;
  $confTemp = $conf['gdThumb'];

  $template->set_filename( 'index_thumbnails', realpath(GDTHUMB_PATH.'template/gdthumb_thumb.tpl'));
  $template->assign('GDThumb', $confTemp);

  $template->assign('GDThumb_derivative_params', ImageStdParams::get_custom(9999, $confTemp['height']));

  if ($confTemp['big_thumb'] and !empty($tpl_vars[0])) {
    $derivative_params = ImageStdParams::get_custom(9999, 2 * $confTemp['height'] + $confTemp['margin']);
    $template->assign('GDThumb_big', new DerivativeImage($derivative_params, $tpl_vars[0]['src_image']));
  }

  return $tpl_vars;
}

function GDThumb_process_category($tpl_vars) {

  global $template, $conf;
  $confTemp = $conf['gdThumb'];

  $template->set_filename( 'index_category_thumbnails', realpath(GDTHUMB_PATH.'template/gdthumb_cat.tpl'));
  $template->assign('GDThumb', $confTemp);
  $template->assign('GDThumb_derivative_params', ImageStdParams::get_custom(9999, $confTemp['height']));

  if ($confTemp['big_thumb'] and !empty($tpl_vars[0])):
    $id = $tpl_vars[0]["representative_picture_id"];
    if (($id) && ($rep = $tpl_vars[0]["representative"])):
      $derivative_params = ImageStdParams::get_custom(9999, 2 * $confTemp['height'] + $confTemp['margin']);
      $template->assign('GDThumb_big', new DerivativeImage($derivative_params, $rep['src_image']));
    endif;
  endif;

  return $tpl_vars;
}

function GDThumb_prefilter($content, $smarty) {
  $pattern = '#\<div.*?id\="thumbnails".*?\>\{\$THUMBNAILS\}\</div\>#';
  $replacement = '<ul id="thumbnails">{$THUMBNAILS}</ul>';

  return preg_replace($pattern, $replacement, $content);
}

function GDThumb_admin_menu($menu) {
  array_push($menu,
    array(
      'NAME' => 'gdThumb',
      'URL' => get_root_url() . 'admin.php?page=plugin-' . basename(dirname(__FILE__)),
    )
  );
  return $menu;
}

function GDThumb_remove_thumb_size() {
  global $template;
  $template->clear_assign('image_derivatives');
}

?>
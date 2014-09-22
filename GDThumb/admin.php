<?php

if (!defined('PHPWG_ROOT_PATH')) die('Hacking attempt!');

function delete_gdthumb_cache($height) {
  $pattern = '#.*-cu_s9999x'.$height.'\.[a-zA-Z0-9]{3,4}$#';
  if ($contents = @opendir(PHPWG_ROOT_PATH.PWG_DERIVATIVE_DIR)):
    while (($node = readdir($contents)) !== false):
      if ($node != '.'
          and $node != '..'
          and is_dir(PHPWG_ROOT_PATH.PWG_DERIVATIVE_DIR.$node)):
        clear_derivative_cache_rec(PHPWG_ROOT_PATH.PWG_DERIVATIVE_DIR.$node, $pattern);
      endif;
    endwhile;
    closedir($contents);
  endif;
}

if (isset($_GET['getMissingDerivative'])) {
  list($max_id, $image_count) = pwg_db_fetch_row( pwg_query('SELECT MAX(id)+1, COUNT(*) FROM '.IMAGES_TABLE) );
  $start_id = intval($_POST['prev_page']);
  $max_urls = intval($_POST['max_urls']);
  if ($start_id<=0) {
    $start_id = $max_id;
  }

  $uid = '&b='.time();
  global $conf;
  $conf['question_mark_in_urls'] = $conf['php_extension_in_urls'] = true;
  $conf['derivative_url_style']=2; //script

  $qlimit = min(5000, ceil(max($image_count/500, $max_urls)));

  $query_model = 'SELECT * FROM ' . IMAGES_TABLE . ' WHERE id < start_id ORDER BY id DESC LIMIT ' . $qlimit;

  $urls=array();
  do {
    $result = pwg_query( str_replace('start_id', $start_id, $query_model));
    $is_last = pwg_db_num_rows($result) < $qlimit;
    while ($row=pwg_db_fetch_assoc($result)) {
      $start_id = $row['id'];
      $src_image = new SrcImage($row);
      if ($src_image->is_mimetype())
        continue;
      $derivative = new DerivativeImage(ImageStdParams::get_custom(9999, $conf['gdThumb']['height']), $src_image);
      if (@filemtime($derivative->get_path())===false) {
        $urls[] = $derivative->get_url().$uid;
      }
      if (count($urls)>=$max_urls && !$is_last)
        break;
    }
    if ($is_last) {
      $start_id = 0;
    }
  }while (count($urls)<$max_urls && $start_id);

  $ret = array();
  if ($start_id) {
    $ret['next_page']=$start_id;
  }
  $ret['urls']=$urls;
  echo json_encode($ret);
  exit();
}

global $template, $conf, $page;

load_language('plugin.lang', GDTHUMB_PATH);
include(dirname(__FILE__).'/config_default.inc.php');
$params = $conf['gdThumb'];

// Delete cache
if (isset($_POST['cachedelete'])) {
  check_pwg_token();
  delete_gdthumb_cache($conf['gdThumb']['height']);
  delete_gdthumb_cache($conf['gdThumb']['height'] * 2 + $conf['gdThumb']['margin']);
  redirect('admin.php?page=plugin-GDThumb');
}

// Save configuration
if (isset($_POST['submit'])) {

  if (empty($_POST['method'])):
    $method = "resize";
  else:
    $method = $_POST['method'];
  endif;

  $big_thumb = !empty($_POST['big_thumb']);
  $params  = array(
    'height'          => $_POST['height'],
    'margin'          => $_POST['margin'],
    'nb_image_page'   => $_POST['nb_image_page'],
    'big_thumb'       => $big_thumb,
    'cache_big_thumb' => !empty($_POST['cache_big_thumb']),
    'normalize_title' => !empty($_POST['normalize_title']),
    'method'          => $method,
    'thumb_mode_album'=> $_POST['thumb_mode_album'],
    'thumb_mode_photo'=> $_POST['thumb_mode_photo'],
    'thumb_metamode'  => $_POST['thumb_metamode'],
    'no_wordwrap'     => !empty($_POST['no_wordwrap'])
  );

  if (!is_numeric($params['height'])) {
    array_push($page['errors'], 'Thumbnails max height must be an integer.');
  }
  if (!is_numeric($params['margin'])) {
    array_push($page['errors'], 'Margin between thumbnails must be an integer.');
  }
  if (!is_numeric($params['nb_image_page'])) {
    array_push($page['errors'], 'Number of photos per page must be an integer.');
  }

  if ($params['height'] != $conf['gdThumb']['height']) {
    delete_gdthumb_cache($conf['gdThumb']['height']);
  }
  elseif ($params['margin'] != $conf['gdThumb']['margin']) {
    delete_gdthumb_cache($conf['gdThumb']['height'] * 2 + $conf['gdThumb']['margin']);
  }

  if (empty($page['errors'])) {
    $query = '
  UPDATE ' . CONFIG_TABLE . '
    SET value="' . addslashes(serialize($params)) . '"
    WHERE param="gdThumb"
    LIMIT 1';
    pwg_query($query);
    
    array_push($page['infos'], l10n('Information data registered in database'));
  }
}

// Try to find GreyDragon Theme and use Theme's styles for admin area
$css_file = dirname(dirname(dirname(__FILE__))) . GDTHEME_PATH . "admin/css/styles.css";
if (file_exists($css_file)):
  $custom_css = "yes";
else:
  $custom_css = "no";
endif;

if (!isset($params['normalize_title'])):
  $params['normalize_title'] = "off";
endif;

// Configuration du template
$template->assign(
  array(
    'GDTHUMB_PATH'     => GDTHUMB_PATH,
    'GDTHEME_PATH'     => GDTHEME_PATH,
    'GDTHUMB_VERSION'  => GDTHUMB_VERSION,
    'PHPWG_ROOT_PATH'  => PHPWG_ROOT_PATH,
    'HEIGHT'           => $params['height'],
    'MARGIN'           => $params['margin'],
    'NB_IMAGE_PAGE'    => $params['nb_image_page'],
    'BIG_THUMB'        => $params['big_thumb'],
    'CACHE_BIG_THUMB'  => $params['cache_big_thumb'],
    'NORMALIZE_TITLE'  => $params['normalize_title'],
    'METHOD'           => $params['method'],
    'THUMB_MODE_ALBUM' => $params['thumb_mode_album'],
    'THUMB_MODE_PHOTO' => $params['thumb_mode_photo'],
    'THUMB_METAMODE'   => $params['thumb_metamode'],
    'NO_WORDWRAP'      => isset($params['no_wordwrap']),
    'PWG_TOKEN'        => get_pwg_token(),
    'CUSTOM_CSS'       => $custom_css
  )
);

$template->set_filenames(array('plugin_admin_content' => dirname(__FILE__) . '/template/admin.tpl'));
$template->assign_var_from_handle('ADMIN_CONTENT', 'plugin_admin_content');

?>
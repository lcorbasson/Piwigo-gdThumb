<?php

if (!defined('PHPWG_ROOT_PATH')) die('Hacking attempt!');

class GDThumb_maintain extends PluginMaintain {
  private $installed = false;
  
  function install($plugin_version, &$errors=array()) {
    include(dirname(__FILE__).'/config_default.inc.php');
    global $conf;
    if (empty($conf['gdThumb'])) {
      $conf['gdThumb'] = serialize($config_default);
      conf_update_param('gdThumb', $conf['gdThumb']);
    }

    $this->installed = true;
  }

  function activate($plugin_version, &$errors=array()) {
    if (!$this->installed) {
      $this->install($plugin_version, $errors);
      $this->cleanUp();
    }
  }

  function deactivate() {
  }

  function uninstall() {
    $this->cleanUp();
    conf_delete_param('gdThumb');
  }

  private function cleanUp() {
    if (is_dir(PHPWG_ROOT_PATH . PWG_LOCAL_DIR . 'GDThumb')) {
      $this->gtdeltree(PHPWG_ROOT_PATH . PWG_LOCAL_DIR . 'GDThumb');
    }
  }

  private function gtdeltree($path) {
    if (is_dir($path)) {
      $fh = opendir($path);
      while ($file = readdir($fh)) {
        if ($file != '.' and $file != '..') {
          $pathfile = $path . '/' . $file;
          if (is_dir($pathfile)) {
            gtdeltree($pathfile);
          }
          else {
            @unlink($pathfile);
          }
        }
      }
      closedir($fh);
      return @rmdir($path);
    }
  }

}
?>
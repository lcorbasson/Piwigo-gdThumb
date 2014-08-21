<div class="titrePage">
<h2>GDThumb</h2>
</div>
{debug}
<form action="" method="post">

<fieldset id="GDThumb">
  <legend>{'Configuration'|@translate}</legend>
  <ul>
    <li><label><span class="graphicalCheckbox {if $APPLY_CAT}icon-check{else}icon-check-empty{/if}">&nbsp;</span><input name="apply_cat" id="apply_cat" type="checkbox" value="1" {if $APPLY_CAT}checked="checked"{/if}>{'Apply to album thumbs'|@translate}</label></li>
    <li><label><span class="graphicalCheckbox {if $APPLY_THUMB}icon-check{else}icon-check-empty{/if}">&nbsp;</span><input name="apply_thumb" id="apply_thumb" type="checkbox" value="1" {if $APPLY_THUMB}checked="checked"{/if}>{'Apply to image thumbs'|@translate}</label></li>
    <li><hr></li>
    <li><label for="height">{'Thumbnails max height'|@translate}</label><input id="height" type="text" size="2" maxlength="3" name="height" value="{$HEIGHT}">&nbsp;px</li>
    <li><label for="margin">{'Margin between thumbnails'|@translate}</label><input id="margin" type="text" size="2" maxlength="3" name="margin" value="{$MARGIN}">&nbsp;px</li>
    <li><label for="nb_image_page">{'Number of photos per page'|@translate}</label><input id="nb_image_page" type="text" size="2" maxlength="3" name="nb_image_page" value="{$NB_IMAGE_PAGE}"></li>

    <li><label><span class="graphicalCheckbox {if $BIG_THUMB}icon-check{else}icon-check-empty{/if}">&nbsp;</span><input name="big_thumb" id="big_thumb" type="checkbox" value="1" {if $BIG_THUMB}checked="checked"{/if}>{'Double the size of the first thumbnail'|@translate}</label></li>
    <li><label><span class="graphicalCheckbox {if $CACHE_BIG_THUMB}icon-check{else}icon-check-empty{/if}">&nbsp;</span><input name="cache_big_thumb" id="cache_big_thumb" type="checkbox" value="1" {if $CACHE_BIG_THUMB}checked="checked"{/if}>{'Cache the big thumbnails (recommended)'|@translate}</label></li>
    <li><label><span class="graphicalCheckbox {if $METHOD == 'crop'}icon-check{else}icon-check-empty{/if}">&nbsp;</span><input name="method" id="method" type="checkbox" value="crop" {if $METHOD == 'crop'}checked="checked"{/if}>{'Scale thumbnails'|@translate}</label></li>

    <li>
      <label for="thumb_mode_album">{'Title Display Mode (Album)'|@translate}</label>
      <select id="thumb_mode_album" name="thumb_mode_album" >
        <option {if $THUMB_MODE_ALBUM=="top"}selected="selected"{/if} value="top">{'Overlay Top'|@translate}</option>
        <option {if $THUMB_MODE_ALBUM=="top_static"}selected="selected"{/if} value="top_static">{'Overlay Top (Static)'|@translate}</option>
        <option {if $THUMB_MODE_ALBUM=="bottom"}selected="selected"{/if} value="bottom">{'Overlay Bottom'|@translate}</option>
        <option {if $THUMB_MODE_ALBUM=="bottom_static"}selected="selected"{/if} value="bottom_static">{'Overlay Bottom (Static)'|@translate}</option>
        <option {if $THUMB_MODE_ALBUM=="hide"}selected="selected"{/if} value="hide">{'Hide'|@translate}</option>
      </select>
    </li>
    <li>
      <label for="thumb_mode_photo">{'Title Display Mode (Photo)'|@translate}</label>
      <select id="thumb_mode_photo" name="thumb_mode_photo" >
        <option {if $THUMB_MODE_PHOTO=="top"}selected="selected"{/if} value="top">{'Overlay Top'|@translate}</option>
        <option {if $THUMB_MODE_PHOTO=="top_static"}selected="selected"{/if} value="top_static">{'Overlay Top (Static)'|@translate}</option>
        <option {if $THUMB_MODE_PHOTO=="bottom"}selected="selected"{/if} value="bottom">{'Overlay Bottom'|@translate}</option>
        <option {if $THUMB_MODE_PHOTO=="bottom_static"}selected="selected"{/if} value="bottom_static">{'Overlay Bottom (Static)'|@translate}</option>
        <option {if $THUMB_MODE_PHOTO=="hide"}selected="selected"{/if} value="hide">{'Hide'|@translate}</option>
      </select>
    </li>
    <li>
      <label for="thumb_metamode">{'Meta Data Display Mode'|@translate}</label>
      <select id="thumb_metamode" name="thumb_metamode" >
        <option {if $THUMB_METAMODE=="merged"}selected="selected"{/if} value="merged">{'Merged (Default)'|@translate}</option>
        <option {if $THUMB_METAMODE=="hide"}selected="selected"{/if} value="hide">{'Hide'|@translate}</option>
      </select>
    </li>
  </ul>
</fieldset>

<p>
  <input type="hidden" name="pwg_token" value="{$PWG_TOKEN}">
  <input type="submit" name="submit" value="{'Submit'|@translate}">
  <input type="submit" name="cachedelete" id="cachedelete" value="{'Purge thumbnails cache'|@translate}" title="{'Delete images in GDThumb cache.'|@translate}" onclick="return confirm('{'Are you sure?'|@translate}');">
  <input type="button" name="cachebuild" id="cachebuild" value="{'Pre-cache thumbnails'|@translate}" title="{'Finds images that have not been cached and creates the cached version.'|@translate}" onclick="jQuery.gdThumb_start();">
</p>
</form>

<fieldset id="generate_cache">
  <legend>{'Pre-cache thumbnails'|@translate}</legend>
  <p class="buttons">
    <input id="startLink" value="{'Start'|@translate}" onclick="jQuery.gdThumb_start()" type="button">
    <input id="pauseLink" value="{'Pause'|@translate}" onclick="jQuery.gdThumb_pause()" type="button" disabled="disbled">
    <input id="stopLink" value="{'Stop'|@translate}" onclick="jQuery.gdThumb_stop()" type="button" disabled="disbled">
  </p>
  <div>
    <ul>
      <li>Loaded:&nbsp;<span id="loaded">0</span></li>
      <li>Remaining:&nbsp;<span id="remaining">0</span></li>
      <li>Errors:&nbsp;<span id="errors">0</span></li>
    </ul>
  </div>
  <div id="feedbackWrap" style="height:{$HEIGHT}px; min-height:{$HEIGHT}px;">
  <img id="feedbackImg">
</div>

<div id="errorList">
</div>
</fieldset>

{combine_css path="/plugins/GDThumb/template/admin.css"}

{if $CUSTOM_CSS=="yes"}
{combine_css path="/themes/greydragon/admin/css/styles.css" version=1}
{footer_script require='jquery.ui.button'}{literal}
$().ready(function(){
  $( ".radio" ).buttonset();
  $('form li label input[type=checkbox]').change(function() { $(this).prev().toggleClass('icon-check icon-check-empty'); });
});
{/literal}{/footer_script}
{else}
{html_head}{literal}
<style type="text/css">
  .graphicalCheckbox { display: none; }
  #generate_cache p.buttons { margin-top: 0; }
</style>
{/literal}{/html_head}
{/if}
{combine_script id='iloader' load='footer' path='plugins/GDThumb/js/image.loader.js'}
{combine_script id='admin.precache' load='footer' path='plugins/GDThumb/js/gdthumb.admin.js' require='jquery.ui.effect-slide' version=2}

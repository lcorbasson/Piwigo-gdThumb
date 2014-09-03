<div class="loader"><img src="{$ROOT_URL}{$themeconf.img_dir}/ajax_loader.gif"></div>
<ul class="thumbnailCategories thumbnails">

{if !empty($category_thumbnails)}
{assign var=has_cats value="true" scope=root nocache}
{foreach from=$category_thumbnails item=cat name=cat_loop}
{assign var=derivative value=$pwg->derivative($GDThumb_derivative_params, $cat.representative.src_image)}
{if !$derivative->is_cached()}
{combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
{combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
{/if}
  <li class="gdthumb">
    {if $GDThumb.thumb_mode_album !== "hide" }
    <span class="thumbLegend {$GDThumb.thumb_mode_album}">
      <span class="thumbName">
        <span class="thumbTitle">{$cat.NAME}
        {if !empty($cat.icon_ts)}
        <img title="{$cat.icon_ts.TITLE}" src="{$ROOT_URL}{$themeconf.icon_dir}/recent{if $cat.icon_ts.IS_CHILD_DATE}_by_child{/if}.png" alt="(!)">
        {/if}
        </span>
        {if $GDThumb.thumb_metamode == "merged"}
        {if isset($cat.INFO_DATES) }
        <span class="dates">{$cat.INFO_DATES}</span>
        {/if}
        <span class="Nb_images">{$cat.CAPTION_NB_IMAGES}</span>
        {if not empty($cat.DESCRIPTION)}
        <span class="description">{$cat.DESCRIPTION}</span>
        {/if}
        {/if}
      </span>
    </span>
    {/if}
    <a href="{$cat.URL}">
      <img class="category thumbnail" {if $derivative->is_cached()}src="{$derivative->get_url()}"{else}src="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" 
        data-src="{$derivative->get_url()}"{/if} alt="{$cat.TN_ALT}" 
        title="{$cat.NAME|@replace:'"':' '|@strip_tags:false}" {$derivative->get_size_htm()}>
    </a>
  </li>
{/foreach}
{/if}

</ul>

{strip}{html_style}
.thumbnailCategories .gdthumb {ldelim} margin:0 0 {$GDThumb.margin}px {$GDThumb.margin}px !important; }
{/html_style}{/strip}

{combine_css path="plugins/GDThumb/template/gdthumb.css" version=1}
{combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
{combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
{combine_script id='jquery.ba-resize' path='plugins/GDThumb/js/jquery.ba-resize.min.js' load="footer"}
{combine_script id='gdthumb' require='jquery,jquery.ba-resize' path='plugins/GDThumb/js/gdthumb.js' load="footer"}

{footer_script require="gdthumb"}
$(function() {
  {if isset($GDThumb_big)}
  {assign var=gt_size value=$GDThumb_big->get_size()}
  var big_thumb = {ldelim}id: {$GDThumb_big->src_image->id}, src: '{$GDThumb_big->get_url()}', width: {$gt_size[0]}, height: {$gt_size[1]}{rdelim};
  {/if}
  GDThumb.setup('{$GDThumb.method}', {$GDThumb.height}, {$GDThumb.margin}, true, big_thumb);
});
{/footer_script}
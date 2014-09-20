{if !empty($thumbnails)}

{foreach from=$thumbnails item=thumbnail}
{assign var=derivative value=$pwg->derivative($GDThumb_derivative_params, $thumbnail.src_image)}
<li class="gdthumb">
  {if $GDThumb.thumb_mode_photo !== "hide" }
  <span class="thumbLegend {$GDThumb.thumb_mode_photo}">
    <span class="thumbName thumbTitle">
    {if $GDThumb.normalize_title == "on"}
      {assign var="file_title" value=$thumbnail.NAME|cat:"."}
      {assign var="file_name" value=$thumbnail.file|replace:"_":" "}
      {if $file_name|strstr:$file_title}
      Photo {$thumbnail.id}
      {else}
      {$thumbnail.NAME}
      {/if}
    {else}
      {$thumbnail.NAME}
    {/if}
      {if !empty($thumbnail.icon_ts)}
      <img title="{$thumbnail.icon_ts.TITLE}" src="{$ROOT_URL}{$themeconf.icon_dir}/recent.png" alt="(!)">
      {/if}
    </span>
    {if $GDThumb.thumb_metamode !== "hide"}
    {if isset($thumbnail.NB_COMMENTS)}
    <span class="{if 0==$thumbnail.NB_COMMENTS}zero {/if}nb-comments">
      {$pwg->l10n_dec('%d comment', '%d comments',$thumbnail.NB_COMMENTS)}
    </span>
    {/if}
    {if isset($thumbnail.NB_COMMENTS) && isset($thumbnail.NB_HITS)} - {/if}
    {if isset($thumbnail.NB_HITS)}
    <span class="{if 0==$thumbnail.NB_HITS}zero {/if}nb-hits">
      {$pwg->l10n_dec('%d hit', '%d hits',$thumbnail.NB_HITS)}
    </span>
    {/if}
    {/if}
  </span>
  {/if}
  <a href="{$thumbnail.URL}">
    <img class="thumbnail" {if $derivative->is_cached()}src="{$derivative->get_url()}"{else}src="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" data-src="{$derivative->get_url()}"{/if} alt="{$thumbnail.TN_ALT}" title="{$thumbnail.TN_TITLE}" {$derivative->get_size_htm()}>
  </a>
</li>
{/foreach}

{combine_css path="plugins/GDThumb/css/gdthumb.css" version=1}
{combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
{combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
{combine_script id='jquery.ba-resize' path='plugins/GDThumb/js/jquery.ba-resize.min.js' load="footer"}
{combine_script id='gdthumb' require='jquery,jquery.ba-resize' path='plugins/GDThumb/js/gdthumb.js' load="footer"}

{footer_script require="gdthumb"}

  {if isset($has_cats)}
  {else}
$(function() {
  {if isset($GDThumb_big)}
  {assign var=gt_size value=$GDThumb_big->get_size()}
  var big_thumb = {ldelim}id: {$GDThumb_big->src_image->id}, src: '{$GDThumb_big->get_url()}', width: {$gt_size[0]}, height: {$gt_size[1]}{rdelim};
  {else}
  var big_thumb = null;
  {/if}
  GDThumb.setup('{$GDThumb.method}', {$GDThumb.height}, {$GDThumb.margin}, false, big_thumb);
});
  {/if}
{/footer_script}

{html_head}
<style type="text/css">#thumbnails .gdthumb {ldelim} margin:0 0 {$GDThumb.margin}px {$GDThumb.margin}px !important; }</style>
<!--[if IE 8]>
<style type="text/css">#thumbnails .gdthumb a {ldelim} right: 0px; }</style>
<![endif]-->
{/html_head}
{/if}
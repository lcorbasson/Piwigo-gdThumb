{if !empty($thumbnails)}
{foreach from=$thumbnails item=thumbnail}
{assign var=derivative value=$pwg->derivative($GDThumb_derivative_params, $thumbnail.src_image)}
<li class="gdthumb">
  {if $GDThumb.thumb_mode_photo !== "hide" }
  <span class="thumbLegend {$GDThumb.thumb_mode_photo}">
    <span class="thumbName thumbTitle">
      {$thumbnail.NAME}
      {if !empty($thumbnail.icon_ts)}
      <img title="{$thumbnail.icon_ts.TITLE}" src="{$ROOT_URL}{$themeconf.icon_dir}/recent.png" alt="(!)">
      {/if}
    </span>
    {if $GDThumb.thumb_metamode == "merged"}
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
    <img class="thumbnail" {if !$derivative->is_cached()}data-{/if}src="{$derivative->get_url()}" alt="{$thumbnail.TN_ALT}" title="{$thumbnail.TN_TITLE}" {$derivative->get_size_htm()}>
  </a>
</li>
{/foreach}

{combine_css path="plugins/GDThumb/template/gdthumb.css" version=1}
{combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
{combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
{combine_script id='jquery.ba-resize' path='plugins/GDThumb/js/jquery.ba-resize.min.js' load="footer"}
{combine_script id='gdthumb' require='jquery,jquery.ba-resize' path='plugins/GDThumb/js/gdthumb.js' load="footer"}

{footer_script require="gdthumb"}

  {if $has_cats=="true"}
  {else}
$(function() {
  GDThumb.max_height = {$GDThumb.height};
  GDThumb.margin = {$GDThumb.margin};
  GDThumb.method = '{$GDThumb.method}';

  {if isset($GDThumb_big)}
  {assign var=gt_size value=$GDThumb_big->get_size()}
  GDThumb.big_thumb = {ldelim}id:{$GDThumb_big->src_image->id},src:'{$GDThumb_big->get_url()}',width:{$gt_size[0]},height:{$gt_size[1]}{rdelim};
  {/if}

  GDThumb.build();
  jQuery(window).bind('RVTS_loaded', GDThumb.build);
  jQuery('ul.thumbnails').resize(GDThumb.process);
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
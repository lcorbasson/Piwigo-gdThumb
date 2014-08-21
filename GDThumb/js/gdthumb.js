var GDThumb = {

  max_height: 200,
  margin: 10,
  max_first_thumb_width: 0.7,
  big_thumb: null,
  small_thumb: null,
  method: 'crop',
  t: new Array,

  build: function () {

    GDThumb.t = new Array;
    $('ul.thumbnails img.thumbnail').each(function(index) {
      width = parseInt(jQuery(this).attr('width'));
      height = parseInt(jQuery(this).attr('height'));
      th = {index:index, width:width, height:height, real_width:width, real_height:height};
      if (height < GDThumb.max_height) {
        th.width = Math.round(GDThumb.max_height * width / height);
        th.height = GDThumb.max_height;
      }
      GDThumb.t.push(th);
    });

    first = GDThumb.t[0];
    GDThumb.small_thumb = {index:first.index,width:first.real_width,height:first.real_height,src:jQuery('ul.thumbnails img.thumbnail:first').attr('src')}

    jQuery.resize.throttleWindow = false;
    jQuery.resize.delay = 50;
    GDThumb.process();
  },

  process: function() {

    var width_count = GDThumb.margin;
    var line = 1;
    var round_rest = 0;
    var main_width = jQuery('ul.thumbnails').width();
    var first_thumb = jQuery('ul.thumbnails img.thumbnail:first');
    var best_size = {width:1,height:1};

    if (GDThumb.big_thumb != null && GDThumb.big_thumb.height < main_width * GDThumb.max_first_thumb_width) {

      // Compute best size for landscape picture (we choose bigger height)
      min_ratio = Math.min(1.05, GDThumb.big_thumb.width/GDThumb.big_thumb.height);

      for(width = GDThumb.big_thumb.width; width/best_size.height>=min_ratio; width--) {
        width_count = GDThumb.margin;
        height = GDThumb.margin;
        max_height = 0;
        available_width = main_width - (width + GDThumb.margin);
        line = 1;
        for (i=1;i<GDThumb.t.length;i++) {

          width_count += GDThumb.t[i].width + GDThumb.margin;
          max_height = Math.max(GDThumb.t[i].height, max_height);

          if (width_count > available_width) {
            ratio = width_count / available_width;
            height += Math.round(max_height / ratio);
            line++;
            max_height = 0;
            width_count = GDThumb.margin;
            if (line > 2) {
              if (height >= best_size.height && width/height >= min_ratio && height<=GDThumb.big_thumb.height) {
                best_size = {width:width,height:height};
              }
              break;
            }
          }
        }
        if (line <= 2) {
          if (max_height == 0 || line == 1) {
            height = GDThumb.big_thumb.height;
          } else {
            height += max_height;
          }
          if (height >= best_size.height && width/height >= min_ratio && height<=GDThumb.big_thumb.height) {
            best_size = {width:width,height:height}
          }
        }
      }

      if (GDThumb.big_thumb.src != first_thumb.attr('src')) {
        first_thumb.attr('src', GDThumb.big_thumb.src).attr({width:GDThumb.big_thumb.width,height:GDThumb.big_thumb.height});
        GDThumb.t[0].width = GDThumb.big_thumb.width;
        GDThumb.t[0].height = GDThumb.big_thumb.height;
      }
      GDThumb.t[0].crop = best_size.width;
      GDThumb.resize(first_thumb, GDThumb.big_thumb.width, GDThumb.big_thumb.height, best_size.width, best_size.height, true);

    }

    if (best_size.width == 1) {
      if (GDThumb.small_thumb != null && GDThumb.small_thumb.src != first_thumb.attr('src')) {  
        first_thumb.prop('src', GDThumb.small_thumb.src).attr({width:GDThumb.small_thumb.width,height:GDThumb.small_thumb.height});
        GDThumb.t[0].width = GDThumb.small_thumb.width;
        GDThumb.t[0].height = GDThumb.small_thumb.height;
      }
      GDThumb.t[0].crop = false;
    }

    width_count = GDThumb.margin;
    max_height = 0;
    line = 1;
    thumb_process = new Array;

    for (i=GDThumb.t[0].crop!=false?1:0;i<GDThumb.t.length;i++) {

      width_count += GDThumb.t[i].width + GDThumb.margin;
      max_height = Math.max(GDThumb.t[i].height, max_height);
      thumb_process.push(GDThumb.t[i]);

      available_width = main_width;
      if (line <= 2 && GDThumb.t[0].crop !== false) {
        available_width -= (GDThumb.t[0].crop + GDThumb.margin);
      }

      if (width_count > available_width) {

        last_thumb = GDThumb.t[i].index;
        ratio = width_count / available_width;
        new_height = Math.round(max_height / ratio);
        round_rest = 0;
        width_count = GDThumb.margin;

        for (j=0;j<thumb_process.length;j++) {

          if (thumb_process[j].index == last_thumb) {
            new_width = available_width - width_count - GDThumb.margin;
          } else {
            new_width = (thumb_process[j].width + round_rest) / ratio;
            round_rest = new_width - Math.round(new_width);
            new_width = Math.round(new_width);
          }
          GDThumb.resize(jQuery('ul.thumbnails img.thumbnail').eq(thumb_process[j].index), thumb_process[j].real_width, thumb_process[j].real_height, new_width, new_height, false);

          width_count += new_width + GDThumb.margin;
        }
        thumb_process = new Array;
        width_count = GDThumb.margin;
        max_height = 0;
        line++;
      }
    }

    // Last line does not need to be cropped
    for (j=0;j<thumb_process.length;j++) {
      GDThumb.resize(jQuery('ul.thumbnails img.thumbnail').eq(thumb_process[j].index), thumb_process[j].real_width, thumb_process[j].real_height, thumb_process[j].width, max_height, false);
    }

    if (main_width != jQuery('ul.thumbnails').width()) {
      GDThumb.process();
    }
  },

  resize: function(thumb, width, height, new_width, new_height, is_big) {

    if (GDThumb.method == 'resize' || height < new_height || width < new_width) {
      real_width = new_width;
      real_height = new_height;
      width_crop = 0;
      height_crop = 0;

      if (is_big) {
        if (width - new_width > height - new_height) {
          real_width = Math.round(new_height * width / height);
          width_crop = Math.round((real_width - new_width)/2);
        } else {
          real_height = Math.round(new_width * height / width);
          height_crop = Math.round((real_height - new_height)/2);
        }
      }
      thumb.css({
        height: real_height+'px',
        width: real_width+'px'
      });
    } else {
      thumb.css({height: '', width: ''});
      height_crop = Math.round((height - new_height)/2);
      width_crop = Math.round((width - new_width)/2);
    }

    thumb.parents('li').css({
      height: new_height+'px',
      width: new_width+'px'
    });
    thumb.parent('a').css({
      clip: 'rect('+height_crop+'px, '+(new_width+width_crop)+'px, '+(new_height+height_crop)+'px, '+width_crop+'px)',
      top: -height_crop+'px',
      left: -width_crop+'px'
    });
  }
}
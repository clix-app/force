ArtworkMasonryView = require '../../../../components/artwork_masonry/view.coffee'

module.exports = ->
  $el = $('.js-artwork-artist-artworks')

  masonryView = new ArtworkMasonryView el: $el

  artworks = $el
    .find '.js-artwork-brick'
    .map -> $(this).data 'id'
    .get()
    .map (id) -> id: id

  masonryView
    .reset artworks
    .postRender()

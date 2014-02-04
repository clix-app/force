_             = require 'underscore'
jade          = require 'jade'
path          = require 'path'
fs            = require 'fs'
cheerio       = require 'cheerio'
Artworks      = require '../../../../collections/artworks.coffee'
Backbone      = require 'backbone'
{ fabricate } = require 'antigravity'
FeaturedSet   = require '../../../../models/featured_set.coffee'
FeaturedLink  = require '../../../../models/featured_link.coffee'
FeaturedLinks = require '../../../../collections/featured_links.coffee'
SaleArtwork   = require '../../../../models/sale_artwork.coffee'

render = (templateName) ->
  filename = path.resolve __dirname, "../../templates/#{templateName}.jade"
  jade.compile(
    fs.readFileSync(filename),
    { filename: filename }
  )

describe 'Featured Sets', ->

  beforeEach ->
    @sd =
      ARTSY_URL : 'http://localhost:5000'
      ASSET_PATH: 'http://localhost:5000'
    @set = new FeaturedSet
      owner      : fabricate('feature', { image_versions: ['wide'] })
      id         : "52b347c59c18db5aef000208"
      published  : true
      key        : "1"
      name       : "The Best of 2013"
      description: "From launching our [mobile app](//link-to-mobile-app) to bringing you fairs, features, and biennials from around the globe, 2013 was a big year at Artsy. Discover our highlights from the past year, and find out what we—and a few of our favorite influencers—think you should keep your eye on in 2014."
      item_type  : "FeaturedLink"
      type       : "featured links"
      owner_type : "Feature"

  describe 'template', ->

    it 'renders the name of the set', ->
      $ = cheerio.load render('sets')({ sets: [ @set ] })
      $('.feature-set-title').should.have.lengthOf 1
      $('.feature-set-title').text().should.equal @set.get('name')

    it 'renders the set description if there is one', ->
      $ = cheerio.load render('sets')({ sets: [ @set ] })
      $('.feature-set-description').should.have.lengthOf 1
      $('.feature-set-description').text().should.equal @set.mdToHtmlToText 'description'

    it 'renders without a title or description', ->
      @set.set { description: null, name: null }
      $ = cheerio.load render('sets')({ sets: [ @set ] })
      $('.feature-set-title').should.have.lengthOf 0
      $('.feature-set-description').should.have.lengthOf 0
      $('.feature-set').should.have.lengthOf 1

  describe "fetured links", ->

    it 'renders a featured link', ->
      @set.set 'data', new FeaturedLinks([ fabricate('featured_link')])
      @html = render('sets')({ sets : [ @set ] })
      $ = cheerio.load render('sets')({ sets: [ @set ] })
      $('.feature-set-item').should.have.lengthOf 1

  describe "sale artworks", ->

    it 'renders sale artworks in an artwork column component', ->
      @set.set 'type', 'sale artworks'
      @set.set 'data', Artworks.fromSale([new SaleArtwork(fabricate('sale_artwork')), new SaleArtwork(fabricate('sale_artwork'))])
      @html = render('sets')({ sets : [ @set ] })
      $ = cheerio.load render('sets')({ sets: [ @set ] })
      $('.feature-set .artwork-column').should.have.lengthOf 3

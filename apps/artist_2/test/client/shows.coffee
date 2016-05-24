_ = require 'underscore'
benv = require 'benv'
sinon = require 'sinon'
Backbone = require 'backbone'
{ resolve } = require 'path'
{ fabricate } = require 'antigravity'
{ stubChildClasses } = require '../../../../test/helpers/stubs'
Artist = require '../../../../models/artist'
artistJSON = require '../fixtures'
Q = require 'bluebird-q'

describe 'ShowsView', ->
  before (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $

      @ShowsView = benv.requireWithJadeify resolve(__dirname, '../../client/views/shows'), ['template']
      @model = new Artist artistJSON
      @ShowsView.__set__ 'metaphysics', @metaphysics = sinon.stub()
      @metaphysics.returns Q.resolve artist:
        current_shows: artistJSON.shows
        past_shows: artistJSON.shows
        upcoming_shows: artistJSON.shows

      stubChildClasses @ShowsView, this,
        ['ArtworkRailView']
        ['remove']
      done()

  after ->
    benv.teardown()

  beforeEach ->
    sinon.stub _, 'defer', (cb) -> cb()
    sinon.stub Backbone, 'sync'
    @view = new @ShowsView model: @model
    sinon.stub @view, 'postRender'
    @view.fetchRelated()

  afterEach ->
    _.defer.restore()
    Backbone.sync.restore()
    @view.remove()

  describe '#render', ->
    it 'renders, sets up the template', ->
      @view.$el.html().should.containEql 'Upcoming Shows and Fair Booths'
      @view.$el.html().should.containEql 'Current Shows and Fair Booths'
      @view.$el.html().should.containEql 'Past Shows'

      @view.$el.find('.grid-item').length.should.eql 6

      @view.$el.find('[data-id=current-shows]').html().should.containEql 'A Show'
      @view.$el.find('[data-id=upcoming-shows]').html().should.containEql 'A Show'
      @view.$el.find('[data-id=past-shows]').html().should.containEql 'A Show'

      @view.$el.find('[data-id=current-shows]').html().should.containEql 'Another Show'
      @view.$el.find('[data-id=upcoming-shows]').html().should.containEql 'Another Show'
      @view.$el.find('[data-id=past-shows]').html().should.containEql 'Another Show'


require 'test_helper'

SITE_ID = '655276a1c36e738ce983a307'.freeze
COLLECTION_ID = '655276efe9424bcefd3231a2'.freeze
CLIENT = Webflow::Client.new(ENV.fetch('TEST_API_TOKEN'))

class WebflowTest < Minitest::Test
  def test_it_fetches_sites
    VCR.use_cassette('test_it_fetches_sites') do
      assert_equal(SITE_ID, CLIENT.sites.first.fetch(:id))
    end
  end

  def test_it_fetches_a_single_site
    VCR.use_cassette('test_it_fetches_a_single_site') do
      assert_equal(SITE_ID, CLIENT.site(SITE_ID).fetch(:id))
    end
  end

  def test_it_publishes_sites
    VCR.use_cassette('test_it_publishes_sites') do
      assert_equal({ customDomains: [], publishToWebflowSubdomain: true }, CLIENT.publish(SITE_ID))
    end
  end

  def test_it_fetches_collections
    VCR.use_cassette('test_it_fetches_collections') do
      assert_equal COLLECTION_ID, CLIENT.collections(SITE_ID).first.fetch(:id)
    end
  end

  def test_it_fetches_a_single_collection
    VCR.use_cassette('test_it_fetches_single_collection') do
      assert_equal COLLECTION_ID, CLIENT.collection(COLLECTION_ID).fetch(:id)
    end
  end

  def test_it_paginates_items
    VCR.use_cassette('test_it_paginates_items') do
      names = ['Test 1', 'Test 2', 'Test 3', 'Test 4']
      names.each { |name| CLIENT.create_item(COLLECTION_ID, { name: name }) }

      page_one = CLIENT.list_items(COLLECTION_ID, limit: 2, offset: 0)
      page_two = CLIENT.list_items(COLLECTION_ID, limit: 2, offset: 2)

      refute_equal(page_one, page_two)
    end
  end

  def test_it_lists_all_items
    VCR.use_cassette('test_it_lists_all_items') do
      CLIENT.list_all_items(COLLECTION_ID) do |items|
        assert_equal(18, items.length)
      end
    end
  end

  def test_it_fetches_a_single_item
    VCR.use_cassette('test_it_fetches_a_single_item') do
      data = { name: 'Test Item Name ABC' }
      item = CLIENT.create_item(COLLECTION_ID, data)

      assert_equal item.fetch(:id), CLIENT.get_item(COLLECTION_ID, item.fetch(:id)).fetch(:id)
    end
  end

  def test_it_creates_and_updates_items
    VCR.use_cassette('test_it_creates_and_updates_items') do
      name = 'Test Item Name ABC'
      data = { name: name }
      item = CLIENT.create_item(COLLECTION_ID, data)

      assert_equal(name, item.dig(:fieldData, :name))

      name = 'Test Item Name Update DEF'
      item = CLIENT.update_item(COLLECTION_ID, item.fetch(:id), { name: name })

      assert_equal(name, item.dig(:fieldData, :name))
    end
  end

  def test_it_creates_drafts_and_archives
    VCR.use_cassette('test_it_creates_drafts_and_archives') do
      name = 'Test Item Name ABC'
      data = { name: name }
      item = CLIENT.create_item(COLLECTION_ID, data, is_draft: true)

      assert(item[:isDraft])

      item = CLIENT.update_item(COLLECTION_ID, item.fetch(:id), {}, is_archived: true)

      assert(item[:isArchived])
    end
  end

  def test_it_raises_validation_errors # rubocop:disable Metrics/MethodLength
    VCR.use_cassette('test_it_raises_validation_errors') do
      data = { unknown: 'this raises an error' }
      begin
        CLIENT.create_item(COLLECTION_ID, data)

        flunk('should have raised')
      rescue StandardError => e
        error = {
          message: %{Validation Error: ["Value (fieldData) should have required property 'name'"]}, code: 'validation_error',
          externalReference: nil, details: []
        }

        assert_equal(error, e.data)
      end
    end
  end

  def test_it_raises_validation_errors_with_problems
    VCR.use_cassette('test_raises_validation_errors_with_problems') do
      CLIENT.create_item(COLLECTION_ID, { name: 'SomeName', field_with_validation: "sh\nrt" })

      flunk('should have raised')
    rescue StandardError => e
      assert_equal(
        'Validation Error: [{param: "field_with_validation", description: "Field not described in schema: undefined"}]',
        e.message
      )
    end
  end

  def test_it_deletes_items
    VCR.use_cassette('test_it_lists_and_deletes_items') do
      names = ['To delete Test 1', 'To delete Test 2']
      names.each { |name| CLIENT.create_item(COLLECTION_ID, { name: name }) }

      CLIENT.list_items(COLLECTION_ID).each do |item|
        next unless item.dig(:fieldData, :name).start_with?('To delete')

        result = CLIENT.delete_item(COLLECTION_ID, item.fetch(:id))

        assert_nil(result)
      end
    end
  end
end

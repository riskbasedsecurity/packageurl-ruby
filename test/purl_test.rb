require "test_helper"

class PurlTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Purl::VERSION
  end

  def test_it_does_something_useful
    test_purls.each do |test_purl|
      if test_purl["is_invalid"]
        assert_raises(Purl::InvalidPurlError, failure_message_for(test_purl)) { Purl.parse(test_purl["purl"]) }

      else
        purl = Purl.parse(test_purl["purl"])

        assert_equal_or_nil test_purl["type"],       purl.type,       failure_message_for(test_purl)
        assert_equal_or_nil test_purl["namespace"],  purl.namespace,  failure_message_for(test_purl)
        assert_equal_or_nil test_purl["name"],       purl.name,       failure_message_for(test_purl)
        assert_equal_or_nil test_purl["version"],    purl.version,    failure_message_for(test_purl)
        assert_equal_or_nil test_purl["qualifiers"], purl.qualifiers, failure_message_for(test_purl)
        assert_equal_or_nil test_purl["subpath"],    purl.subpath,    failure_message_for(test_purl)

        assert_equal test_purl["canonical_purl"], purl.to_s(:canonical)
      end
    end
  end

  private

    def test_purls
      JSON.parse(
        File.read(
          File.join(File.expand_path('..', __FILE__), 'fixtures/files/test_purls.json')
        )
      )
    end

    def failure_message_for(test_purl)
      "Failed parsing: #{test_purl["purl"]}"
    end

    def assert_equal_or_nil(expected, actual, *args)
      if expected.nil?
        assert_nil actual, *args
      else
        assert_equal expected, actual, *args
      end
    end
end

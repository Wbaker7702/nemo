# frozen_string_literal: true

# Creates CSVs with byte-order mark to assist Excel in opening files.
class UserFacingCSV
  BOM = "\xEF\xBB\xBF"

  def self.generate(**options, &)
    CSV.generate(BOM.dup, **defaults.merge(options), &)
  end

  def self.open(filename, mode = "rb", **options, &)
    # Prepend BOM.
    unless mode.include?("r")
      File.open(filename, mode) do |f|
        f << BOM
      end
    end
    CSV.open(filename, "ab", **defaults.merge(options), &)
  end

  def self.defaults
    # We default to \r\n for CSV row separator because Excel seems to prefer it.
    {row_sep: "\r\n"}
  end
end

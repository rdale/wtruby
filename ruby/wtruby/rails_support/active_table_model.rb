=begin
This table model allows an ActiveRecord or ActiveResource to be used as a
basis for a Wt::WAbstractTableModel for viewing in a Wt::Ext::TableView.
 
Example usage:

class TableApplication < Wt::WApplication
  def initialize(env)
    super(env)
    agencies = TravelAgency.find(:all)
    model = Wt::ActiveTableModel.new(agencies)
    w = Wt::WContainerWidget.new(root)
    table = Wt::Ext::TableView.new(w)
    table.resize(Wt::WLength.new(500), Wt::WLength.new(175))
    table.model = model
  end
end

Wt::WRun(ARGV) do |env|
  TableApplication.new(env)
end

Written by Richard Dale and Silvio Fonseca

=end

require 'wt'
require 'date'

module Wt
  class ActiveTableModel < Wt::WAbstractTableModel
    def initialize(collection, columns = nil, parent = nil)
      super(parent)
      @collection = collection
      if columns
        if columns.kind_of? Hash
          @keys=columns.keys
          @labels=columns.values
        else
          @keys=columns
        end
      else
        @keys = build_keys([], @collection.first.attributes)
      end
      @labels ||= @keys.collect { |k| k.humanize.gsub(/\./, ' ') }
    end

    def build_keys(keys, attrs, prefix="")
      attrs.inject(keys) do |cols, a|
        if a[1].respond_to? :attributes
          build_keys(cols, a[1].attributes, prefix + a[0] + ".")
        else
          cols << prefix + a[0]
        end
      end
    end

    def rowCount(parent)
      @collection.size
    end

    def columnCount(parent)
      @keys.size
    end

    def [](row)
      row = row.row if row.is_a? Wt::WModelIndex
      @collection[row]
    end

    def column(name)
      @keys.index name
    end

    def data(index, role = Wt::DisplayRole)
      return Boost::Any.new unless role == Wt::DisplayRole or role == Wt::EditRole
      item = @collection[index.row]
      return Boost::Any.new if item.nil?
      raise "invalid column #{index.column}" if (index.column < 0 ||
          index.column >= @keys.size)
      value = eval("item['%s']" % @keys[index.column].gsub(/\./, "']['"))
      return Boost::Any.new(value)
    end

    def headerData(section, orientation, role = Wt::DisplayRole)
      return Boost::Any.new unless role == Wt::DisplayRole
      value = case orientation
      when Wt::Horizontal
          @labels[section]
      else
          section
      end
      return Boost::Any.new(value)
    end

    def flags(index)
      return Wt::ItemIsEditable.to_i | super(index)
    end

    def setData(index, variant, role = Wt::EditRole)
      if index.valid? and role == Wt::EditRole
        att = @keys[index.column]
        # Don't allow the primary key to be changed
        if att == 'id'
          return false
        end

        item = @collection[index.row]
        raise "invalid column #{index.column}" if (index.column < 0 ||
            index.column >= @keys.size)
        value = variant.value

        if value.class.name == "Wt::WDate"
          value = Date.new(value.year, value.month, value.day)
        end

        eval("item['%s'] = value" % att.gsub(/\./, "']['"))
        item.save
        dataChanged.emit(index, index)
        return true
      else
        return false
      end
    end

  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

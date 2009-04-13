=begin

This Wt::WAbstractItemModel based model allows an ActiveRecord or ActiveResource
data set to be used as a basis for viewing in a Wt::WTreeView. 

Example usage:

class TreeViewApplication < Wt::WApplication
  def initialize(env)
    super(env)
    agencies = TravelAgency.find(:all)
    model = Wt::ActiveItemModel.new(agencies)
    w = Wt::WContainerWidget.new(root)
    tree = Wt::WTreeView.new(w)
    tree.resize(Wt::WLength.new(1000), Wt::WLength.new(175))
    tree.model = model
  end
end

Wt::WRun(ARGV) do |env|
  TreeViewApplication.new(env)
end

You can pass a list of just the columns you want to display:

  model = Wt::ActiveItemModel.new(products, ['title', 'price'])

Or a hash of label and column names:

  model = Wt::ActiveItemModel.new(products, {'title' => 'My Title', 'price' = 'Price'})


Written by Richard Dale and Silvio Fonseca

=end

require 'wt'
require 'date'

module Wt

  class TreeItem
    attr_reader :childItems, :resource, :itemData

    def initialize(item, keys, parent = nil, prefix="")
      @keys = keys
      @parentItem = parent
      @childItems = []
      @resource = item
      if @resource.respond_to? :attributes
        @resource.attributes.inject(@itemData = {}) do |data, a|
          if a[1].respond_to? :attributes
            TreeItem.new(a[1], @keys, self, prefix + a[0] + ".")
          else
            data[prefix + a[0]] = a[1]
          end
          data
        end
      else
        @itemData = item
      end

      if @parentItem
        @parentItem.appendChild(self)
      end
    end
    
    def appendChild(item)
      @childItems.push(item)
    end
    
    def child(row)
      return @childItems[row]
    end
    
    def childCount
      return @childItems.length
    end
    
    def columnCount
      return @itemData.length
    end
    
    def data(column)
      return Boost::Any.new(@itemData[@keys[column]])
    end
    
    def parent
      return @parentItem
    end
    
    def row
      if !@parentItem.nil?
        return @parentItem.childItems.index(self)
      end
    
      return 0
    end
  end

  class ActiveItemModel < Wt::WAbstractItemModel  
    def initialize(collection, columns = nil, parent = nil)
      super(parent)
      @collection = collection
      if columns
        if columns.kind_of? Hash
          @keys = columns.keys
          @labels = columns.values
        else
          @keys = columns
        end
      else
        @keys = build_keys([], @collection.first.attributes)
      end

      if @labels.nil?
        @keys.inject(@labels = {}) do |labels, k| 
          labels[k] = k.humanize.gsub(/\./, ' ')
          labels 
        end
      end

      @rootItem = TreeItem.new(@labels, @keys)
      @collection.each do |row|
        TreeItem.new(row, @keys, @rootItem)
      end
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

    def [](row)
      row = row.row if row.is_a? Wt::WModelIndex
      @collection[row]
    end

    def column(name)
      @keys.index name
    end
    
    def columnCount(parent)
      if parent.valid?
        return parent.internalPointer.columnCount
      else
        return @rootItem.columnCount
      end
    end
    
    def data(index, role)
      if !index.valid?
        return Boost::Any.new
      end
    
      if role != Wt::DisplayRole
        return Boost::Any.new
      end
    
      item = index.internalPointer
      return item.data(index.column)
    end

    def setData(index, variant, role = Wt::EditRole)
      if index.valid? and role == Wt::EditRole
        raise "invalid column #{index.column}" if (index.column < 0 ||
          index.column >= @keys.size)

        att = @keys[index.column]
        item = index.internalPointer

        if ! item.itemData.has_key? att
          return false
        end

        value = variant.value

        if value.class.name == "Wt::WDate"
          value = Date.new(value.year, value.month, value.day)
        end

        att.gsub!(/.*\.(.*)/, '\1')
        # Don't allow the primary key to be changed
        if att == 'id'
          return false
        end

        eval("item.resource['%s'] = value" % att)
        item.resource.save
        dataChanged.emit(index, index)
        return true
      else
        return false
      end
    end
    
    def flags(index)
      if !index.valid?
        return 0
      end
    
      return Wt::ItemIsSelectable.to_i | Wt::ItemIsEditable.to_i
    end
    
    def headerData(section, orientation, role)
      if orientation == Wt::Horizontal && role == Wt::DisplayRole
        return Boost::Any.new(@labels[@keys[section]])
      end
    
      return Boost::Any.new
    end
    
    def index(row, column, parent)
      if !parent.valid?
        parentItem = @rootItem
      else
        parentItem = parent.internalPointer
      end
    
      @childItem = parentItem.child(row)
      if @childItem
        return createIndex(row, column, @childItem)
      else
        return Wt::WModelIndex.new
      end
    end
    
    def parent(index)
      if !index.valid?
        return Wt::WModelIndex.new
      end
    
      childItem = index.internalPointer
      parentItem = childItem.parent
    
      if parentItem == @rootItem
        return Wt::WModelIndex.new
      end
    
      return createIndex(parentItem.row, 0, parentItem)
    end
    
    def rowCount(parent)
      if !parent.valid?
        parentItem = @rootItem
      else
        parentItem = parent.internalPointer
      end
    
      return parentItem.childCount
    end
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

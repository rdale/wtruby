#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#
# Translated to Ruby by Richad Dale

def readFromCsv(f, model, numRows = -1, firstLineIsHeaders = true)
  csvRow = 0

  f.readlines.each do |line|
    line.split(',').each_with_index do |value, col|
      if col >= model.columnCount
        model.insertColumns(model.columnCount, col + 1 - model.columnCount)
      end

      if firstLineIsHeaders && csvRow == 0
        model.setHeaderData(col, Boost::Any.new(value.sub(/^"(.*)"$/, '\1')))
      else
        dataRow = firstLineIsHeaders ? csvRow - 1 : csvRow
        if numRows != -1 && dataRow >= numRows
          return
        end

        if dataRow >= model.rowCount
          model.insertRows(model.rowCount, dataRow + 1 - model.rowCount)
        end
        
        if value =~ /^\d+$/
          data = Boost::Any.new(value.to_i)
        elsif value =~ /^\d+\.\d+$/
          data = Boost::Any.new(value.to_f)
        elsif value =~ /^"(.*)"$/
          data = Boost::Any.new($1)
        else
          data = Boost::Any.new(value)
        end
        model.setData(dataRow, col, data)
      end
    end

    csvRow += 1
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

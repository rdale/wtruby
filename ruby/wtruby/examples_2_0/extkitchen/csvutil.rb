#
# Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.
#
# See the LICENSE file for terms of use.
#

def readFromCsv(f, model, firstLineIsHeaders = true)
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

        if dataRow >= model.rowCount
          model.insertRows(model.rowCount, dataRow + 1 - model.rowCount)
        end
        
        model.setData(dataRow, col, Boost::Any.new(value.sub(/^"(.*)"$/, '\1')))
      end
    end

    csvRow += 1
  end
end


# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

=begin
  Dumps a tree of WObjects given a root instance

  Example usage:

  puts "__________________________________________________ OBJECT DUMP"
  dump_objects($wApp.root)
  puts "__________________________________________________ OBJECT SWEEP"
  ObjectSpace.each_object(Wt::Base) do |obj|
    puts "#{obj.inspect}"
  end
  puts "__________________________________________________"

  Written by: Richard Dale, Jan 2009
=end

DUMP_INDENT = '  '

def dump_objects(obj, indent = DUMP_INDENT)
  puts "#{indent}#{obj.inspect}"

  begin
    puts "#{indent}#{DUMP_INDENT}#{obj.layout.inspect}" unless obj.layout.nil?
  rescue
  end

  begin
    dump_objects(obj.subMenu, indent + DUMP_INDENT)
  rescue
  end

  begin
    obj.items.each do |item|
      dump_objects(item, indent + DUMP_INDENT)
      dump_objects(obj.item_contents[item.id], indent + DUMP_INDENT + DUMP_INDENT) unless obj.item_contents[item.id].nil?
    end
  rescue
  end

  begin
    obj.children.each do |child|
      dump_objects(child, indent + DUMP_INDENT)
    end
  rescue
  end
end

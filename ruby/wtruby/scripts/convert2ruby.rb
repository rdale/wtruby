#!/usr/bin/ruby

#
# Script for converting the Wt C++ examples to Ruby.
#
# The results aren't perfect, but it's a lot easier than
# doing everything by hand.
#
# Usage:
#     convert2ruby FooBar
#
# Opens FooBar.h and FooBar.C, and creates foobar.rb as output
#
# Copyright (C) 2008 Richard Dale
#

WT_CLASSNAMES = [  
  "Chart::SeriesIterator",
  "Chart::WAbstractChart",
  "Chart::WAxis",
  "Chart::WCartesianChart",
  "Chart::WChart2DRenderer",
  "Chart::WChartPalette",
  "Chart::WDataSeries",
  "Chart::WPieChart",
  "Chart::WStandardPalette",
  "Ext::AbstractButton",
  "Ext::AbstractToggleButton",
  "Ext::Button",
  "Ext::Calendar",
  "Ext::CheckBox",
  "Ext::ComboBox",
  "Ext::Component",
  "Ext::Container",
  "Ext::DataStore",
  "Ext::DataStore::Column",
  "Ext::DateField",
  "Ext::Dialog",
  "Ext::Dialog::Bla",
  "Ext::FormField",
  "Ext::LineEdit",
  "Ext::Menu",
  "Ext::MenuItem",
  "Ext::MessageBox",
  "Ext::NumberField",
  "Ext::PagingToolBar",
  "Ext::Panel",
  "Ext::ProgressDialog",
  "Ext::RadioButton",
  "Ext::Splitter",
  "Ext::SplitterHandle",
  "Ext::TabWidget",
  "Ext::TableView",
  "Ext::TableView::ColumnModel",
  "Ext::TextEdit",
  "Ext::ToolBar",
  "Ext::ToolTipConfig",
  "Ext::Widget",
  "WAbstractArea",
  "WAbstractItemModel",
  "WAbstractToggleButton",
  "WAccordionLayout",
  "WAnchor",
  "WApplication",
  "WApplication::UpdateLock",
  "WBorder",
  "WBorderLayout",
  "WBoxLayout",
  "WBreak",
  "WBrush",
  "WButtonGroup",
  "WCalendar",
  "WCanvasPaintDevice",
  "WCheckBox",
  "WCircleArea",
  "WColor",
  "WComboBox",
  "WCompositeWidget",
  "WContainerWidget",
  "WCssDecorationRule",
  "WCssDecorationStyle",
  "WCssOtherRule",
  "WCssRule",
  "WCssStyleSheet",
  "WDate",
  "WDatePicker",
  "WDateValidator",
  "WDefaultLayout",
  "WDialog",
  "WDoubleValidator",
  "WDropEvent",
  "WEnvironment",
  "WFileResource",
  "WFileUpload",
  "WFitLayout",
  "WFont",
  "WFormWidget",
  "WGridLayout",
  "WGroupBox",
  "WHBoxLayout",
  "WIconPair",
  "WImage",
  "WInPlaceEdit",
  "WIntValidator",
  "WInteractWidget",
  "WKeyEvent",
  "WLabel",
  "WLayout",
  "WLayoutItem",
  "WLength",
  "WLengthValidator",
  "WLineEdit",
  "WLineF",
  "WLogEntry",
  "WLogger",
  "WLogger::Field",
  "WMemoryResource",
  "WMenu",
  "WMenuItem",
  "WMessageBox",
  "WMessageResourceBundle",
  "WMessageResources",
  "WModelIndex",
  "WMouseEvent",
  "WMouseEvent::Coordinates",
  "WObject",
  "WPaintDevice",
  "WPaintedWidget",
  "WPainter",
  "WPainter::Image",
  "WPainterPath",
  "WPainterPath::Segment",
  "WPanel",
  "WPen",
  "WPoint",
  "WPointF",
  "WPolygonArea",
  "WPushButton",
  "WRadioButton",
  "WRectArea",
  "WRectF",
  "WRegExpValidator",
  "WResource",
  "WResponseEvent",
  "WScrollArea",
  "WScrollBar",
  "WSelectionBox",
  "WServer",
  "WSlider",
  "WSocketNotifier",
  "WStackedWidget",
  "WStandardItemModel",
  "WStatelessSlot",
  "WSuggestionPopup",
  "WSuggestionPopup::Options",
  "WSvgImage",
  "WTabWidget",
  "WTable",
  "WTableCell",
  "WTableColumn",
  "WTableRow",
  "WText",
  "WTextArea",
  "WTextEdit",
  "WTimer",
  "WTimerWidget",
  "WTransform",
  "WTree",
  "WTreeNode",
  "WTreeTable",
  "WTreeTableNode",
  "WVBoxLayout",
  "WValidationStatus",
  "WValidator",
  "WVectorImage",
  "WViewWidget",
  "WVirtualImage",
  "WVmlImage",
  "WWebWidget",
  "WWidget",
  "WWidgetItem" ]

WT_ENUMNAMES = [
  "white",
  "black",
  "red",
  "darkRed",
  "green",
  "darkGreen",
  "blue",
  "darkBlue",
  "cyan",
  "darkCyan",
  "magenta",
  "darkMagenta",
  "yellow",
  "darkYellow",
  "gray",
  "darkGray",
  "lightGray",
  "transparent",
  "Horizontal",
  "Vertical",
  "NoButton",
  "Ok",
  "Cancel",
  "Yes",
  "No",
  "Abort",
  "Retry",
  "Ignore",
  "YesAll",
  "NoAll",
  "NoIcon",
  "Information",
  "Warning",
  "Critical",
  "Question",
  "NoSelection",
  "SingleSelection",
  "ExtendedSelection",
  "SelectItems",
  "SelectRows",
  "CellSelection",
  "RowSelection",
  "None",
  "Top",
  "Bottom",
  "Left",
  "Right",
  "CenterX",
  "CenterY",
  "CenterXY",
  "Verticals",
  "Horizontals",
  "All",
  "AlignBaseline",
  "AlignSub",
  "AlignSuper",
  "AlignTop",
  "AlignTextTop",
  "AlignMiddle",
  "AlignBottom",
  "AlignTextBottom",
  "AlignLength",
  "AlignLeft",
  "AlignRight",
  "AlignCenter",
  "AlignJustify",
  "Static",
  "Relative",
  "Absolute",
  "Fixed",
  "ArrowCursor",
  "AutoCursor",
  "CrossCursor",
  "PointingHandCursor",
  "OpenHandCursor",
  "WaitCursor",
  "IBeamCursor",
  "WhatsThisCursor",
  "TargetSelf",
  "TargetThisWindow",
  "TargetNewWindow",
  "LocalEncoding",
  "UTF8",
  "MatchExactly",
  "MatchStringExactly",
  "MatchStartsWith",
  "MatchEndsWith",
  "MatchRegExp",
  "MatchWildCard",
  "MatchCaseSensitive",
  "MatchWrap",
  "NoBrush",
  "SolidPattern",
  "NoPen",
  "SolidLine",
  "DashLine",
  "DotLine",
  "DashDotLine",
  "DashDotDotLine",
  "FlatCap",
  "SquareCap",
  "RoundCap",
  "MiterJoin",
  "BevelJoin",
  "RoundJoin",
  "NoModifier",
  "ShiftModifier",
  "ControlModifier",
  "AltModifier",
  "MetaModifier",
  "Key_unknown",
  "Key_Enter",
  "Key_Tab",
  "Key_Backspace",
  "Key_Shift",
  "Key_Control",
  "Key_Alt",
  "Key_PageUp",
  "Key_PageDown",
  "Key_End",
  "Key_Home",
  "Key_Left",
  "Key_Up",
  "Key_Right",
  "Key_Down",
  "Key_Insert",
  "Key_Delete",
  "Key_Escape",
  "Key_F1",
  "Key_F2",
  "Key_F3",
  "Key_F4",
  "Key_F5",
  "Key_F6",
  "Key_F7",
  "Key_F8",
  "Key_F9",
  "Key_F10",
  "Key_F11",
  "Key_F12",
  "Key_Space",
  "Key_A",
  "Key_B",
  "Key_C",
  "Key_D",
  "Key_E",
  "Key_F",
  "Key_G",
  "Key_H",
  "Key_I",
  "Key_J",
  "Key_K",
  "Key_L",
  "Key_M",
  "Key_N",
  "Key_O",
  "Key_P",
  "Key_Q",
  "Key_R",
  "Key_S",
  "Key_T",
  "Key_U",
  "Key_V",
  "Key_W",
  "Key_X",
  "Key_Y",
  "Key_Z",
  "DomElement_A",
  "DomElement_BR",
  "DomElement_BUTTON",
  "DomElement_COL",
  "DomElement_DIV",
  "DomElement_FIELDSET",
  "DomElement_FORM",
  "DomElement_H1",
  "DomElement_H2",
  "DomElement_H3",
  "DomElement_H4",
  "DomElement_H5",
  "DomElement_H6",
  "DomElement_IFRAME",
  "DomElement_IMG",
  "DomElement_INPUT",
  "DomElement_LABEL",
  "DomElement_LEGEND",
  "DomElement_LI",
  "DomElement_OL",
  "DomElement_OPTION",
  "DomElement_UL",
  "DomElement_SCRIPT",
  "DomElement_SELECT",
  "DomElement_SPAN",
  "DomElement_TABLE",
  "DomElement_TBODY",
  "DomElement_TD",
  "DomElement_TEXTAREA",
  "DomElement_TR",
  "DomElement_P",
  "DomElement_CANVAS",
  "DomElement_MAP",
  "DomElement_AREA",
  "XHTMLText",
  "XHTMLUnsafeText",
  "PlainText",
  "XHTMLFormatting",
  "XHTMLUnsafeFormatting",
  "PlainFormatting" ]

def resolve_classnames(line)
  WT_CLASSNAMES.each do |name|
    line.gsub!(Regexp.new("(^|[^\\w:])(#{name}([^\\w]|$))"), '\1Wt::\2')

    if name =~ /^Chart::(.*)/
      line.gsub!(Regexp.new("(^|[^\\w:])(#{$1}([^\\w]|$))"), '\1Wt::Chart::\2')
    end

    if name =~ /^Ext::(.*)/
      line.gsub!(Regexp.new("(^|[^\\w:])(#{$1}([^\\w]|$))"), '\1Wt::Ext::\2')
    end
  end
  return line
end

# new FooBar(a, b) ==> FooBar.new(a, b)
def convert_heap_constructor(line)
  return line.sub(/new\s+([\w:]+)/, '\1.new')
end

# baz(FooBar(a, b), c) ==> baz(FooBar.new(a, b), c)
def convert_arg_constructor(line)
  WT_CLASSNAMES.each do |name|
    line.gsub!(Regexp.new("(#{name})\\("), '\1.new(')
  end
  return line
end

# FooBar f(a, b) ==> f = FooBar.new(a, b)
def convert_stack_constructor(line)
  WT_CLASSNAMES.each do |name|
    line.gsub!(Regexp.new("^(\\s*)(#{name})\\s+([\\w]+)(\\(.*\\))?"), '\1\3 = \2.new\4')
  end
  return line
end

def convert_enumnames(line)
  if line =~ /("[^"]*")/
    # if the line contains a string, give up for now
    return line
  end

  WT_ENUMNAMES.each do |name|
    line.gsub!(Regexp.new("([^\\w:])(#{name}[^\\w])"), '\1Wt::\2')
  end

  return line
end

source_name = ARGV[0]
$output_file = File.open("#{source_name.downcase}.rb", "w")

$instance_variable_substitutions = ""

def convert_line(line)
  line.sub!(%r{^\s?(\s*)\*/}) {|s| "#{$1}#"}
  line.sub!(/^\s?(\s*)\*/) {|s| "#{$1}#"}
  line.sub!(%r{^\s?(\s*)/\*}) {|s| "#{$1}#"}
  line.sub!(%r{//}, '#')
  line.sub!(/! \\brief/, '')
  line.sub!(/\\defgroup/, '')
  line.sub!(/@addtogroup/, '')

  line.gsub!(/\t/, '        ')
  line.sub!(/;\s*$/, '')
  line.sub!(/\);(\s*#)/, ')\2')
  line.gsub!(/->/, '.')
  line.sub!(/this/, 'self')
  line.gsub!(/L"/, '"')

  # class FooBar: public WContainerWidget ==> class FooBar < Wt::WContainerWidget
  if line =~ /class\s+(\w+)\s*:\s*public\s*([:\w]+)\s*\{?/
    $current_class = $1
    $current_superclass = resolve_classnames($2)
    line = "class " + $current_class + " < " + $current_superclass
  end

  line.sub!(/set(?:Padding|Margin)\((\d+)/, 'setMargin(Wt::WLength.new(\1)')
  line.sub!(/resize\((\d+),\s*(\d+)\)/, 'resize(Wt::WLength.new(\1), Wt::WLength.new(\2))')

  line.sub!(/push_back\(/, 'push(')

  line.gsub!(/WString::tr/, 'tr')
  line.gsub!(/WString\(("[^\)]*")\)/, '\1')

  line.sub!(/Wt::widen\((\w+)\)/, '\1')
  line.sub!(/Wt::narrow\((\w+)\)/, '\1')
  line.sub!(/\.c_str\(\)/, '')
  line.sub!(/boost::lexical_cast<std::w?string>\(([^\)]+)\)/, '\1.to_s')

  line.sub!(/(\w+)\+\+/, '\1 += 1')
  line.sub!(/\+\+(\w+)/, '\1 += 1')
  line.sub!(/(\w+)\-\-/, '\1 -= 1')
  line.sub!(/\-\-(\w+)/, '\1 -= 1')

  line.gsub!(/\w+\s*\*\s*([a-zA-Z])/) {|m| $1}
  return line
end

def convert_args(args)
  args.gsub!(/[\*\&]/, ' ')
  return args.split(',').map {|arg| arg.sub(/^.*\s(\w+)\s*$/, '\1') }.join(', ')
end

def skip_line?(line)
  line =~ /^#/ ||
  line =~ /(using )?\s*namespace\s+\w+(\s+\{)?/ ||
  line =~ /^\s*class \w+\s*;$/ ||
  line =~ /this is a -\*-C\+\+-\*- file/ ||
  line =~ /This may look like C code/ ||
  line =~ /^\/\*@\{\*\// ||
  line =~ /^\s*\{\s*$/
end

#
# Parse the header file. Only keep the class definition and
# the variable names, and discard the rest.
#
File.exist?("#{source_name}.h") && File.open("#{source_name}.h", "r").readlines.each do |line|
  if skip_line?(line)
    next
  end

  if line =~ /^[\w<>:\s]+\s*[\s\*]>?\s*(\w+);$/
    cvar = $1
    rvar = $1.clone
    rvar.sub!(/^(.)/) {|m| "@" + $1.downcase}
    rvar.gsub!(/_/, '')
    $instance_variable_substitutions += "line.gsub!(/(^|[^\\w\.])#{cvar}([^\\w]|$)/) {|m| $1 + '#{rvar}' + $2}\n"
  end

  line = convert_line(line)

  if line =~ /^class/ || line =~ /^\s*#/
    $output_file.puts line
  end
end

#
# Parse the implementation file
#
def parse_line(line)
  if $current_class
    # Constructor
    if line =~ Regexp.new("#{$current_class}::#{$current_class}")
      while line !~ /\{/ do
        line += $input_file.gets
      end
      line.gsub!(/\n/, '')
      line.gsub!(/\{\s*$/, '')
      line.sub!(Regexp.new("\\s*(?:#{$current_class}::#{$current_class})\\(([^\\)]*)\\)\s*:(.*)")) do |m| 
        "  def initialize(#{convert_args($1)})"
      end
      if $2
        init_list = $2.split('),').each do |item|
          item.sub!(/^\s*/, '')
          item = resolve_classnames(item)
          if item =~ Regexp.new("\s*#{$current_superclass}\\((.*)\\)")
            line += "\n    super(#{convert_args($1)})"
          else
            line += "\n    " + item.sub(/\(/, ' = ').sub(/\)/, '')
          end
        end
      end
    end

    # Ordinary method
    line.sub!(Regexp.new("[\\w:]+(?:(?:\\s*\[\\*\\&]\\s*)?|\\s+)#{$current_class}::(\\w+)\\((.*)(\\)?)(?: const)?")) do |m| 
      "  def #{$1}(#{convert_args($2)}#{$3}"
    end
  end

  if line =~ /WApplication\s*\*\s*createApplication\(const\s*WEnvironment\s*\&\s*env\)/
    line = "Wt::WRun(ARGV) do |env|"
  end

  # for(unsigned int i = 0; i < 26; ++i)  ==>  for i in 0...26
  if line =~ /(.*)for\s*\(.*\s+(\w+)\s*=\s*(\w+);\s*\w+\s*(<=?)\s*([\w\(\)\.>-]+)/
    line = $1 + "for " + $2 + " in " + $3 + ($4 == '<' ? "..." : "..") + $5
  end

  line = convert_line(line)

  line.sub!(/case\s*(.*):/, 'when \1:')
  line.sub!(/switch\s*\((.*)\)\s*\{/, 'case \1')

  line.sub!(/if\s*\((.*)\)\s*\{/, 'if \1')
  line.sub!(/if\s*\((.*)\)\s*$/, 'if \1')
  line.sub!(/\}\s*else\s*if/, 'elsif')
  line.sub!(/\}\s*else\s*\{/, 'else')
  line.sub!(/(\s*)\}\s*$/) {|s| $1 + '  end'}

  line = convert_heap_constructor(line)
  line = convert_arg_constructor(line)
  line = convert_stack_constructor(line)

  line.sub!(/SLOT\(\s*\&?(\w+),\s*\w+:(:\w+)\)/, 'SLOT(\1, \2)')

  eval($instance_variable_substitutions)
  resolve_classnames(line)
  convert_enumnames(line)

  line.sub!(/\.set(\w)(\w+)\(([^\,]+)\)[^\)]*$/) {|m| ".#{$1.downcase}#{$2} = #{$3}"}
  line.gsub!(/\(\)/, '')

  return line
end

$input_file = File.open("#{source_name}.C", "r")
while line = $input_file.gets do
  if skip_line?(line)
    next
  end

  line = parse_line(line)
  $output_file.puts line
end


$output_file.puts "end\n"
$output_file.puts "\n# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;"


# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;


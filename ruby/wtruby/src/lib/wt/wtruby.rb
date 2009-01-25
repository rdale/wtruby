=begin
/***************************************************************************
                          wtruby.rb  -  description
                             -------------------
    begin                : Fri Jul 4 2003 (derived from the qtruby.rb source)
    copyright            : (C) 2003-2008 by Richard Dale
    email                : richard.j.dale@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
=end

module Wt
  module DebugLevel
    Off, Minimal, High, Extensive = 0, 1, 2, 3
  end

  module WtDebugChannel 
    WTDB_NONE = 0x00
    WTDB_AMBIGUOUS = 0x01
    WTDB_METHOD_MISSING = 0x02
    WTDB_CALLS = 0x04
    WTDB_GC = 0x08
    WTDB_VIRTUAL = 0x10
    WTDB_VERBOSE = 0x20
    WTDB_ALL = WTDB_VERBOSE | WTDB_VIRTUAL | WTDB_GC | WTDB_CALLS | WTDB_METHOD_MISSING | WTDB_AMBIGUOUS
  end

  @@debug_level = DebugLevel::Off
  def Wt.debug_level=(level)
    @@debug_level = level
    Internal::setDebug Wt::WtDebugChannel::WTDB_ALL if level >= DebugLevel::Extensive
  end

  def Wt.debug_level
    @@debug_level
  end
    
  class Base
    def tr(key)
      return Wt::WWidget.tr(key)
    end

    def **(a)
      return Wt::**(self, a)
    end
    def +(a)
      return Wt::+(self, a)
    end
    def ~(a)
      return Wt::~(self, a)
    end
    def -@()
      return Wt::-(self)
    end
    def -(a)
      return Wt::-(self, a)
    end
    def *(a)
      return Wt::*(self, a)
    end
    def /(a)
      return Wt::/(self, a)
    end
    def %(a)
      return Wt::%(self, a)
    end
    def >>(a)
      return Wt::>>(self, a)
    end
    def <<(a)
      return Wt::<<(self, a)
    end
    def &(a)
      return Wt::&(self, a)
    end
    def ^(a)
      return Wt::^(self, a)
    end
    def |(a)
      return Wt::|(self, a)
    end

#    Module has '<', '<=', '>' and '>=' operator instance methods, so pretend they
#    don't exist by calling method_missing() explicitely
    def <(a)
      begin
        Wt::method_missing(:<, self, a)
      rescue
        super(a)
      end
    end

    def <=(a)
      begin
        Wt::method_missing(:<=, self, a)
      rescue
        super(a)
      end
    end

    def >(a)
      begin
        Wt::method_missing(:>, self, a)
      rescue
        super(a)
      end
    end

    def >=(a)
      begin
        Wt::method_missing(:>=, self, a)
      rescue
        super(a)
      end
    end

#    Object has a '==' operator instance method, so pretend it
#    don't exist by calling method_missing() explicitely
    def ==(a)
      begin
        Wt::method_missing(:==, self, a)
      rescue
        super(a)
      end
    end

    def self.ancestors
      klass = self
      classid = nil
      loop do
        classid = Wt::Internal::find_pclassid(klass.name)
        break if classid.index
  
        klass = klass.superclass
        if klass.nil?
          return super
        end
      end

      klasses = super
      klasses.delete(Wt::Base)
      klasses.delete(self)
      ids = []
      Wt::Internal::getAllParents(classid, ids)
      return [self] + ids.map {|id| Wt::Internal.find_class(Wt::Internal.classid2name(id))} + klasses
    end


    def methods(regular=true)
      if !regular
        return singleton_methods
      end
  
      wt_methods(super, 0x0)
    end
  
    def protected_methods
      # From smoke.h, Smoke::mf_protected 0x80
      wt_methods(super, 0x80)
    end
  
    def public_methods
      methods
    end
  
    def singleton_methods
      # From smoke.h, Smoke::mf_static 0x01
      wt_methods(super, 0x01)
    end
  
    private
    def wt_methods(meths, flags)
      ids = []
      # These methods are all defined in Wt::Base, even if they aren't supported by a particular
      # subclass, so remove them to avoid confusion
      meths -= ["%", "&", "*", "**", "+", "-", "-@", "/", "<", "<<", "<=", ">", ">=", ">>", "|", "~", "^"]
      classid = Wt::Internal::idInstance(self)
      Wt::Internal::getAllParents(classid, ids)
      ids << classid
      ids.each { |c| Wt::Internal::findAllMethodNames(meths, c, flags) }
      return meths.uniq
    end
  end # Wt::Base

  class Chart::WAbstractChart < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Chart::WAxis < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Chart::WCartesianChart < Wt::Base
    def type(*args)
      method_missing(:type, *args)
    end

    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class Chart::WDataSeries < Wt::Base
    def type(*args)
      method_missing(:type, *args)
    end
  end

  class Chart::WPieChart < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WAbstractItemModel < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end
  end

  class WAbstractToggleButton < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WAnchor < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WApplication < Wt::Base
    def initialize(env)
      super(env)
      $wApp = self
    end 

    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WBreak < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WButtonGroup < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WCalendar < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WCanvasPaintDevice < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WCheckBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WColor < Wt::Base
    def inspect
      str = super
      str.sub(/>$/, " cssText='%s', name='%s'>" % [cssText, name])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n cssText='%s',\n name='%s'>" % [cssText, name])
    end

    def name(*args)
      method_missing(:name, *args)
    end
  end

  class WComboBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WCompositeWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WContainerWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WDate < Wt::Base
    def initialize(*args)
      if args.size == 1 && args[0].class.name == "Date"
        return super(args[0].year, args[0].month, args[0].day)
      elsif args.size == 1 && args[0].class.name == "Time"
        return super(args[0].year, args[0].month, args[0].day)
      else
        return super(*args)
      end
    end

    def inspect
      str = super
      str.sub(/>$/, " %s>" % toString)
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, " %s>" % toString)
    end
  end

  class WDatePicker < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WDateValidator < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WDialog < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def exec(*args)
      method_missing(:exec, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WDoubleValidator < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end

    def range=(arg)
      if arg.kind_of? Range
        setBottom(arg.begin)
        setTop(arg.exclude_end?  ? arg.end - 1 : arg.end)
      else
        return super(arg)
      end
    end
  end

  class WFileResource < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WFileUpload < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WFormWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WGroupBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WIconPair < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, state=%d>" % [id, state])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n %d>" % [id, state])
    end
  end

  class WImage < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WInPlaceEdit < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WIntValidator < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end

    def range=(arg)
      if arg.kind_of? Range
        setBottom(arg.begin)
        setTop(arg.exclude_end?  ? arg.end - 1 : arg.end)
      else
        return super(arg)
      end
    end
  end

  class WInteractWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WLabel < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WLength < Wt::Base
    Unit = [  "FontEm",
              "FontEx",
              "Pixel",
              "Inch",
              "Centimeter",
              "Millimeter",
              "Point",
              "Pica",
              "Percentage" ]

    def inspect
      str = super
      str.sub(/>$/, " value=%s unit=%s>" % [value, Unit[unit.to_i]])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "value=%s,\n unit=%s>" % [value, Unit[unit.to_i]])
    end
  end

  class WLengthValidator < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WLineEdit < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, text='%s'>" % [id, text])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n text='%s'>" % [id, text])
    end
  end

  class WLineF < Wt::Base
    def inspect
      str = super
      str.sub(/>$/, " x1=%f, y1=%f, x2=%f, y2=%f>" % [x1, y1, x2, y2])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n x1=%f,\n y1=%f,\n x2=%f,\n y2=%f>" % [x1, y1, x2, y2])
    end
  end

  class WMemoryResource < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WMenu < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%sm items=Array (%d element(s))>" % [id, items.length])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s\n items=Array (%d element(s))>" % [id, items.length])
    end
  end

  class WMenuItem < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def select(*args)
      method_missing(:select, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, text='%s'>" % [id, text])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n text='%s'>" % [id, text])
    end
  end

  class WMessageBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def exec(*args)
      method_missing(:exec, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WObject < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WPaintedWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WPanel < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WPainterPath < Wt::Base
    class Segment < Wt::Base
      def type(*args)
        method_missing(:type, *args)
      end
    end
  end

  class WPoint < Wt::Base
    def inspect
      str = super
      str.sub(/>$/, " x=%d, y=%d>" % [self.x, self.y])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n x=%d,\n y=%d>" % [self.x, self.y])
    end
  end
  
  class WPointF < Wt::Base
    def inspect
      str = super
      str.sub(/>$/, " x=%f, y=%f>" % [self.x, self.y])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n x=%f,\n y=%f>" % [self.x, self.y])
    end
  end

  class WPolygonArea < Wt::Base
    include Enumerable

    def each
      points.each do |point|
        yield point
      end
      return self
    end
  end

  class WPushButton < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WRadioButton < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WRectF < Wt::Base
    def inspect
      str = super
      str.sub(/>$/, " x=%f, y=%f, width=%f, height=%f>" % [x, y, width, height])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n x=%f,\n y=%f,\n width=%f,\n height=%f>" % [x, y, width, height])
    end
  end

  class WRegExpValidator < Wt::Base
    def initialize(*args)
      if args.size == 1 && args[0].class.name == "String"
        @regExp = args[0]
      end

      return super(*args)
    end

    def setRegExp(arg)
      @regExp = arg
      super(arg)
    end

    def regExp=(arg)
      setRegExp(arg)
    end

    def regExp
      return Regexp.new(@regExp)
    end

    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s regExp=%s>" % [id, regExp.inspect])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n regExp=%s>" % [id, regExp.inspect])
    end
  end

  class WScrollArea < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WScrollBar < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WSelectionBox < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WSlider < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%d, minimum=%d, maximum=%d, value=%d>" % [id, minimum, maximum, value])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n minimum=%d,\n maximum=%d,\n value=%d>" % [id, minimum, maximum, value])
    end

    def range=(arg)
      if arg.kind_of? Range
        setMinimum(arg.begin)
        setMaximum(arg.exclude_end?  ? arg.end - 1 : arg.end)
      else
        return super(arg)
      end
    end

  end

  class WSocketNotifier < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def type(*args)
      method_missing(:type, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WStackedWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WStandardItemModel < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WStatelessSlot < Wt::Base
    def type(*args)
      method_missing(:type, *args)
    end
  end

  class WSubMenuItem < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def select(*args)
      method_missing(:select, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, text='%s'>" % [id, text])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n text='%s'>" % [id, text])
    end
  end

  class WSuggestionPopup < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WSvgImage < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTabWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTable < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, rowCount=%d, columnCount=%d>" % [id, rowCount, columnCount])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n rowCount=%d,\n columnCount=%d>" % [id, rowCount, columnCount])
    end
  end

  class WTableCell < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, row=%d, column=%d>" % [id, row, column])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n row=%d,\n column=%d>" % [id, row, column])
    end
  end

  class WTableColumn < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, columnNum=%d>" % [id, columnNum])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n columnNum>" % [id, columnNum])
    end
  end

  class WTableRow < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, rowNum=%d>" % [id, rowNum])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n rowNum>" % [id, rowNum])
    end
  end

  class WText < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, text='%s'>" % [id, text])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s,\n text='%s'>" % [id, text])
    end
  end

  class WTextArea < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTextEdit < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTimer < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s, interval=%d, active?=%s, singleShot?=%s>" % [id, interval, isActive, isSingleShot])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\nid=%s,\n interval=%d,\n active?=%s,\n singleShot?=%s>" % [id, interval, isActive, isSingleShot])
    end
  end

  class WTimerWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTree < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTreeNode < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTreeTable < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WTreeTableNode < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WValidationStatus < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WValidator < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WViewWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WVirtualImage < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WWebWidget < Wt::Base

    def id(*args)
      method_missing(:id, *args)
    end

    def load(*args)
      method_missing(:load, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  class WWidget < Wt::Base
    def id(*args)
      method_missing(:id, *args)
    end

    def inspect
      str = super
      str.sub(/>$/, " id=%s>" % [id])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n id=%s>" % [id])
    end
  end

  # WSignalMapper
  # A utility class to connect multiple senders to a single slot.
  #
  # This class is useful if you have to respond to the same signal of
  # many objects or widgets, but need to identify the sender through some
  # property.
  #
  # Consider the following example, where you can check for the sender, by
  # adding it as a mapped argument:
  #
  #   def createWidgets()
  #     myMap = Wt::WSignalMapper.new(self)
  #
  #     myMap.mapped.connect(SLOT(self, :onClick))
  #     myMap.mapConnect(text1.clicked, text1)
  #     myMap.mapConnect(text2.clicked, text2)
  #     myMap.mapConnect(text3.clicked, text3)
  #   end
  #
  #   def onClick(source)
  #     source is where it is coming from
  #     ...
  #   end
  #
  # The mapper may pass one extra argument from the original signal to the
  # WSignalMapper#mapped signal. In that case, you must connect the original 
  # signal to the map1() slot, or use mapConnect1().
  #
  class WSignalMapper < Wt::WObject
    attr_reader :mapped

    def initialize(parent = nil)
      super
      @mappings = {}
      @mapped = Wt::Signal2.new(self)
    end

    def setMapping(sender, data)
      @mappings[sender] = data
    end

    def mapConnect(signal, data)
      @mappings[signal.sender] = data
      signal.connect(SLOT(self, :map))
    end

    def mapConnect1(signal, data)
      @mappings[signal.sender] = data
      signal.connect(SLOT(self, :map1))
    end

    def map
      data = @mappings[sender()]
      @mapped.emit(data, nil)
    end

    def map1(a)
      data = @mappings[sender()]
      @mapped.emit(data, a)
    end
  end

  # A widget that implements a view for a non-changing model.
  #
  # This model uses a target instance and method symbol to call, which is 
  # passed in the constructor to render the View, and does not react to 
  # changes.
  #
  # You may want to use the utility method Wt.makeStaticModel() to create an
  # instance of this class.
  class WStaticModelView < Wt::WViewWidget
    def initialize(method, target, parent = nil)
      super(parent)
      @method = method
      @target = target
    end

    def renderView
      @target.send(@method)
    end
  end

  def Wt.makeStaticModel(method, target, parent = nil)
    return WStaticModelView.new(method, target, parent)
  end

  class RubyStatelessSlot    
    AutoLearnStateless  = 0
    PreLearnStateless   = 1
    JavaScriptSpecified = 2

    attr_accessor :method, :target, :undoMethod, :jscript, :learned

    def initialize(obj, method, opt = nil)
      @target = obj
      @method = method
      if opt.nil? || opt.kind_of?(Symbol)
         @undoMethod = opt
         @learned = false
      else
         @jscript = opt
         @learned = true
      end
    end

    def type
      if @method.nil?
        return JavaScriptSpecified
      elsif @undoMethod.nil?
        return AutoLearnStateless
      else
        return PreLearnStateless
      end
    end
  end

  # Provides a mutable numeric class for passing to methods with
  # C++ 'int*' or 'int&' arg types
  class Integer
    attr_accessor :value
    def initialize(n=0) @value = n end
    
    def +(n) 
      return Integer.new(@value + n.to_i) 
    end
    def -(n) 
      return Integer.new(@value - n.to_i)
    end
    def *(n) 
      return Integer.new(@value * n.to_i)
    end
    def /(n) 
      return Integer.new(@value / n.to_i)
    end
    def %(n) 
      return Integer.new(@value % n.to_i)
    end
    def **(n) 
      return Integer.new(@value ** n.to_i)
    end
    
    def |(n) 
      return Integer.new(@value | n.to_i)
    end
    def &(n) 
      return Integer.new(@value & n.to_i)
    end
    def ^(n) 
      return Integer.new(@value ^ n.to_i)
    end
    def <<(n) 
      return Integer.new(@value << n.to_i)
    end
    def >>(n) 
      return Integer.new(@value >> n.to_i)
    end
    def >(n) 
      return @value > n.to_i
    end
    def >=(n) 
      return @value >= n.to_i
    end
    def <(n) 
      return @value < n.to_i
    end
    def <=(n) 
      return @value <= n.to_i
    end
    
    def <=>(n)
      if @value < n.to_i
        return -1
      elsif @value > n.to_i
        return 1
      else
        return 0
      end
    end
    
    def to_f() return @value.to_f end
    def to_i() return @value.to_i end
    def to_s() return @value.to_s end
    
    def coerce(n)
      [n, @value]
    end
  end
  
  # If a C++ enum was converted to an ordinary ruby Integer, the
  # name of the type is lost. The enum type name is needed for overloaded
  # method resolution when two methods differ only by an enum type.
  class Enum
    attr_accessor :type, :value
    def initialize(n, enum_type)
      @value = n 
      @type = enum_type
    end
    
    def +(n) 
      return @value + n.to_i
    end
    def -(n) 
      return @value - n.to_i
    end
    def *(n) 
      return @value * n.to_i
    end
    def /(n) 
      return @value / n.to_i
    end
    def %(n) 
      return @value % n.to_i
    end
    def **(n) 
      return @value ** n.to_i
    end
    
    def |(n) 
      return Enum.new(@value | n.to_i, @type)
    end
    def &(n) 
      return Enum.new(@value & n.to_i, @type)
    end
    def ^(n) 
      return Enum.new(@value ^ n.to_i, @type)
    end
    def ~() 
      return ~ @value
    end
    def <(n) 
      return @value < n.to_i
    end
    def <=(n) 
      return @value <= n.to_i
    end
    def >(n) 
      return @value > n.to_i
    end
    def >=(n) 
      return @value >= n.to_i
    end
    def <<(n) 
      return Enum.new(@value << n.to_i, @type)
    end
    def >>(n) 
      return Enum.new(@value >> n.to_i, @type)
    end
    
    def ==(n) return @value == n.to_i end
    def to_i() return @value end

    def to_f() return @value.to_f end
    def to_s() return @value.to_s end
    
    def coerce(n)
      [n, @value]
    end
    
    def inspect
      to_s
    end

    def pretty_print(pp)
      pp.text "#<%s:0x%8.8x @type=%s, @value=%d>" % [self.class.name, object_id, type, value]
    end
  end
  
  # Provides a mutable boolean class for passing to methods with
  # C++ 'bool*' or 'bool&' arg types
  class Boolean
    attr_accessor :value
    def initialize(b=false) @value = b end
    def nil? 
      return !@value 
    end
  end
  
  module Internal
    @@classes   = {}
    @@cpp_names = {}
    @@idclass   = []

    @@normalize_procs = []

    class ModuleIndex
      attr_accessor :index

      def smoke
        if ! @smoke
            return 0
        end
        return @smoke
      end
      
      def initialize(smoke, index)
        @smoke = smoke
        @index = index
      end
    end

    def self.classes
      return @@classes
    end

    def self.cpp_names
      return @@cpp_names
    end

    def self.idclass
      return @@idclass
    end

    def self.add_normalize_proc(func)
      @@normalize_procs << func
    end

    def Internal.normalize_classname(classname)
      @@normalize_procs.each do |func|
        ret = func.call(classname)
        if !ret.nil?
          return ret
        end
      end
      if classname =~ /^boost/
        ruby_classname = classname.gsub(/(^.)/) {|m| m.upcase}.gsub(/::(.)/) {|m| m.upcase}
      else
        ruby_classname = classname
      end
      return ruby_classname
    end

    def Internal.init_class(c)
      if c == "QGlobalSpace" || c == "Wt::Ext"
        return
      end
      classname = Wt::Internal::normalize_classname(c)
      classId = Wt::Internal.findClass(c)
      insert_pclassid(classname, classId)
      @@idclass[classId.index] = classname
      @@cpp_names[classname] = c
      if c =~/^Wt::Chart/
        klass = create_wt_class(classname, Wt::Chart)
      elsif c =~/^boost::signals/
        klass = create_wt_class(classname, Boost::Signals)
      elsif c =~/^boost/
        klass = create_wt_class(classname, Boost)
      else
        klass = create_wt_class(classname, Wt)
      end
      @@classes[classname] = klass unless klass.nil?
    end

    def Internal.debug_level
      Wt.debug_level
    end

    def Internal.checkarg(argtype, typename)
      puts "      #{typename} (#{argtype})" if debug_level >= DebugLevel::High
      if argtype == 'i'
        if typename =~ /^int&?$|^signed int&?$|^signed$/
          return 2
        elsif typename =~ /^(?:short|ushort|unsigned short int|unsigned short|char|uchar|uint|long|ulong|unsigned long int|unsigned|float|double)$/
          return 1
        elsif typename =~ /^(long long)|(unsigned long long)$/
          return 1
        else 
          t = typename.sub(/^const\s+/, '')
          t.sub!(/[&*]$/, '')
          if isEnum(t)
            return 0
          end
        end
      elsif argtype == 'n'
        if typename =~ /^double$/
          return 2
        elsif typename =~ /^float$/
          return 1
        elsif typename =~ /^int&?$/
          return 0
        elsif typename =~ /^(?:short|ushort|uint|long|ulong|signed|unsigned|float|double)$/
          return 0
        else 
          t = typename.sub(/^const\s+/, '')
          t.sub!(/[&*]$/, '')
          if isEnum(t)
            return 0
          end
        end
      elsif argtype == 'B'
        if typename =~ /^(?:bool)[*&]?$/
          return 0
        end
      elsif argtype == 's'
        if typename =~ /^(const )?((QChar)[*&]?)$/
          return 1
        elsif typename =~ /^(const )?std::vector<char>[*&]?$/
          return 0
        elsif typename =~ /^(?:u?char\*|(?:const )?(std::w?string[*&]?)|const u?char\*|(?:const )?(Wt::WString)[*&]?)$/
          wstring = !$1.nil?
          return $1 ? 2 : ($2 ? 3 : 0)
        end
      elsif argtype == 'a'
      elsif argtype == 'u'
        # Give nil matched against string types a higher score than anything else
        if typename =~ /^(?:u?char\*|const u?char\*|(?:const )?((Wt::WString))[*&]?)$/
          return 1
        # Numerics will give a runtime conversion error, so they fail the match
        elsif typename =~ /^(?:short|ushort|uint|long|ulong|signed|unsigned|int)$/
          return -99
        else
          return 0
        end
      elsif argtype == 'U'
        if typename =~ /WStringList/
          return 1
        else
          return 0
        end
      else
        t = typename.sub(/^const\s+/, '')
        t.sub!(/(::)?Ptr$/, '')
        t.sub!(/[&*]$/, '')
        if argtype == t
          return 1
        elsif classIsa(argtype, t)
          return 0
        elsif isEnum(argtype) and 
            (t =~ /int|uint|long|ulong/ or isEnum(t))
          return 0
        end
      end
      return -99
    end

    def Internal.find_class(classname)
      @@classes[classname]
    end
    
    # Runs the initializer as far as allocating the Wt C++ instance.
    # Then use a throw to jump back to here with the C++ instance 
    # wrapped in a new ruby variable of type T_DATA
    def Internal.try_initialize(instance, *args)
      initializer = instance.method(:initialize)
      catch "new_wt" do
        initializer.call(*args)
      end
    end
    
        # If a block was passed to the constructor, then
    # run that now. Either run the context of the new instance
    # if no args were passed to the block. Or otherwise,
    # run the block in the context of the arg.
    def Internal.run_initializer_block(instance, block)
      if block.arity == -1
        instance.instance_eval(&block)
      elsif block.arity == 1
        block.call(instance)
      else
        raise ArgumentError, "Wrong number of arguments to block(#{block.arity} for 1)"
      end
    end

    def Internal.do_method_missing(package, method, klass, this, *args)
      if klass.class == Module
        classname = klass.name
      else
        classname = @@cpp_names[klass.name]
        if classname.nil?
          if klass != Object
            return do_method_missing(package, method, klass.superclass, this, *args)
          else
            return nil
          end
        end
      end

      if method == "new"
        method = classname.dup 
        method.gsub!(/^.*::/,"")
      end
      method = "operator" + method.sub("@","") if method !~ /[a-zA-Z]+/
      # Change foobar= to setFoobar()          
      method = 'set' + method[0,1].upcase + method[1,method.length].sub("=", "") if method =~ /.*[^-+%\/|=]=$/ && method != 'operator='

      methods = []
      methods << method.dup
      args.each do |arg|
        if arg.nil?
          # For each nil arg encountered, triple the number of munged method
          # templates, in order to cover all possible types that can match nil
          temp = []
          methods.collect! do |meth| 
            temp << meth + '?' 
            temp << meth + '#'
            meth << '$'
          end
          methods.concat(temp)
        elsif isObject(arg)
          methods.collect! { |meth| meth << '#' }
        elsif arg.kind_of? Array or arg.kind_of? Hash
          methods.collect! { |meth| meth << '?' }
        else
          methods.collect! { |meth| meth << '$' }
        end
      end
      
      methodIds = []
      methods.collect { |meth| methodIds.concat( findMethod(classname, meth) ) }
      
      if method =~ /._./ && methodIds.length == 0
        # If the method name contains underscores, convert to camel case
        # form and try again
        method.gsub!(/(.)_(.)/) {$1 + $2.upcase}
        return do_method_missing(package, method, klass, this, *args)
      end

      if debug_level >= DebugLevel::High
        puts "classname    == #{classname}"
        puts ":: method == #{method}"
        puts "-> methodIds == #{methodIds.inspect}"
        puts "candidate list:"
        prototypes = dumpCandidates(methodIds).split("\n")
        line_len = (prototypes.collect { |p| p.length }).max
        prototypes.zip(methodIds) { 
          |prototype,id| puts "#{prototype.ljust line_len}  (smoke: #{id.smoke} index: #{id.index})" 
        }
      end
      
      chosen = nil
      if methodIds.length > 0
        best_match = -1
        methodIds.each do
          |id|
          puts "matching => smoke: #{id.smoke} index: #{id.index}" if debug_level >= DebugLevel::High
          current_match = 0
          (0...args.length).each do
            |i|
            current_match += checkarg(get_value_type(args[i]), get_arg_type_name(id, i))
          end
          
          # Note that if current_match > best_match, then chosen must be nil
          if current_match > best_match
            best_match = current_match
            chosen = id
          # Multiple matches are an error; the equality test below _cannot_ be commented out.
          # If ambiguous matches occur the problem must be fixed be adjusting the relative
          # ranking of the arg types involved in checkarg().
          elsif current_match == best_match
            chosen = nil
          end
          puts "match => #{id.index} score: #{current_match}" if debug_level >= DebugLevel::High
        end
          
        puts "Resolved to id: #{chosen.index}" if !chosen.nil? && debug_level >= DebugLevel::High
      end

      if debug_level >= DebugLevel::Minimal && chosen.nil? && method !~ /^operator/
        id = find_pclassid(normalize_classname(klass.name))
        hash = findAllMethods(id)
        constructor_names = nil
        if method == classname
          puts "No matching constructor found, possibles:\n"
          constructor_names = hash.keys.grep(/^#{classname}/)
        else
          puts "Possible prototypes:"
          constructor_names = hash.keys
        end
        method_ids = hash.values_at(*constructor_names).flatten
        puts dumpCandidates(method_ids)
      else
        puts "setCurrentMethod(smokeList index: #{chosen.smoke}, meth index: #{chosen.index})" if chosen && debug_level >= DebugLevel::High
      end
      setCurrentMethod(chosen) if chosen
      return nil
    end

    def Internal.init_all_classes()
      Wt::Internal::getClassList().each do |c|
        if !c.empty?
          Wt::Internal::init_class(c)
        end
      end

      @@classes['Wt::Integer'] = Wt::Integer
      @@classes['Wt::Boolean'] = Wt::Boolean
      @@classes['Wt::Enum'] = Wt::Enum
    end
    
    def Internal.get_winteger(num)
      return num.value
    end
    
    def Internal.set_winteger(num, val)
      return num.value = val
    end
    
    def Internal.create_wenum(num, enum_type)
      return Wt::Enum.new(num, enum_type)
    end
    
    def Internal.get_wenum_type(e)
      return e.type
    end
    
    def Internal.get_wboolean(b)
      return b.value
    end
    
    def Internal.set_wboolean(b, val)
      return b.value = val
    end

    def Internal.getAllParents(class_id, res)
      getIsa(class_id).each do |s|
        c = findClass(s)
        res << c
        getAllParents(c, res)
      end
    end

  end # Wt::Internal
end # Wt

module Boost
  class Any < Wt::Base
    def empty?
      empty
    end

    def inspect
      str = super
      str.sub(/>$/, " type=%s>" % [name])
    end
    
    def pretty_print(pp)
      str = to_s
      pp.text str.sub(/>$/, "\n type=%s>" % [name])
    end
  end
end

class Object
  def SLOT(x, y)
    if x.respond_to?(y)
      return [x, y, x.method(y).arity]
    else
      return [x, y, 0]
    end
  end
end

class Module
  alias_method :_constants, :constants
  alias_method :_instance_methods, :instance_methods
  alias_method :_protected_instance_methods, :protected_instance_methods
  alias_method :_public_instance_methods, :public_instance_methods

  private :_constants, :_instance_methods
  private :_protected_instance_methods, :_public_instance_methods

  def constants
    wt_methods(_constants, 0x10, true)
  end

  def instance_methods(inc_super=true)
    wt_methods(_instance_methods(inc_super), 0x0, inc_super)
  end

  def protected_instance_methods(inc_super=true)
    wt_methods(_protected_instance_methods(inc_super), 0x80, inc_super)
  end

  def public_instance_methods(inc_super=true)
    wt_methods(_public_instance_methods(inc_super), 0x0, inc_super)
  end

  private
  def wt_methods(meths, flags, inc_super=true)
    if !self.kind_of? Class
      return meths
    end

    klass = self
    classid = Wt::Internal::ModuleIndex.new(0, 0)
    loop do
      classid = Wt::Internal::find_pclassid(klass.name)
      break if classid.index
      
      klass = klass.superclass
      if klass.nil?
        return meths
      end
    end

    # These methods are all defined in Wt::Base, even if they aren't supported by a particular
    # subclass, so remove them to avoid confusion
    meths -= ["%", "&", "*", "**", "+", "-", "-@", "/", "<", "<<", "<=", ">", ">=", ">>", "|", "~", "^"]
    ids = []
    if inc_super
      Wt::Internal::getAllParents(classid, ids)
    end
    ids << classid
    ids.each { |c| Wt::Internal::findAllMethodNames(meths, c, flags) }
    return meths.uniq
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

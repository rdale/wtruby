#!/usr/bin/ruby

=begin
 Copyright (C) 2008 Emweb bvba, Kessel-Lo, Belgium.

 See the LICENSE file for terms of use.

 Translated to Ruby by Richard Dale
=end

require 'wt'
require 'date'
require 'datevalidator.rb'
require 'form.rb'

# formexample Form example

# Main widget for the %Form example.
#
# This class demonstrates, next instantiating the form itself,
# handling of different languages.
#/

class FormExample < Wt::WContainerWidget
  def initialize(parent = nil)
    super(parent)
    langLayout = Wt::WContainerWidget.new(self)
    langLayout.setContentAlignment(Wt::AlignRight)
    Wt::WText.new(tr("language"), langLayout)

    lang = ["en", "nl"]
    @languageSelects = []

    for i in 0..lang.length do
      t = Wt::WText.new(lang[i], langLayout)
      t.margin = Wt::WLength.new(5)
      t.clicked.connect(SLOT(self, :changeLanguage))

      @languageSelects << t
    end

    # Start with the reported locale, if available
    #
    setLanguage($wApp.locale)

    @form = Form.new(self)
    @form.margin = Wt::WLength.new(20)
  end

  def setLanguage(lang)
    haveLang = false

    for i in 0...@languageSelects.length do
      t = @languageSelects[i]
  
      # prefix match, e.g. en matches en-us.
      isLang = lang.include?(t.text)
      t.styleClass = (isLang ? "langcurrent" : "lang")
  
      haveLang = haveLang || isLang
    end
  
    if !haveLang
      @languageSelects[0].styleClass = "langcurrent"
      $wApp.locale = @languageSelects[0].text
    else
      $wApp.locale = lang
    end
  end

  def changeLanguage
    t = sender()
    setLanguage(t.text)
  end
end


Wt::WRun(ARGV) do |env|
  app = Wt::WApplication.new(env)
  app.messageResourceBundle().use("form-example")
  app.title = "Form example"

  app.root.addWidget(FormExample.new)

  langStyle = Wt::WCssDecorationStyle.new
  langStyle.font.size = Wt::WFont::Smaller
  langStyle.cursor = Wt::PointingHandCursor
  langStyle.foregroundColor = Wt::WColor.new(Wt::blue)
  langStyle.textDecoration = Wt::WCssDecorationStyle::Underline
  app.styleSheet.addRule(".lang", langStyle)

  langStyle.cursor = Wt::ArrowCursor
  langStyle.font.weight = Wt::WFont::Bold
  app.styleSheet.addRule(".langcurrent", langStyle)

  app
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

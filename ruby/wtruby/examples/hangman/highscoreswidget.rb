# Copyright (C) 2005 Wim Dumon
#
# See the LICENSE file for terms of use.
#
class HighScoresWidget < Wt::WContainerWidget

  def initialize(user, parent = nil)
    super(parent)
    @user = user
    setContentAlignment(Wt::AlignCenter)
    setStyleClass("highscores")
  end

  def update
#    clear
  
    title = Wt::WText.new("Hall of fame", self)
    title.decorationStyle.font.size = Wt::WFont::XLarge
    title.setMargin(Wt::WLength.new(10), Wt::Top | Wt::Bottom)
  
    Wt::WBreak.new(self)
  
    u, s = HangmanDb.getUserPosition(@user)
  
    if s == 1
      yourScore = "Congratulations! You are currently leading the pack."
    else 
      yourScore = "You are currently ranked number " + s.to_s + ". Almost there!"
    end
  
    score = Wt::WText.new("<p>" + yourScore + "</p>", self)
    score.decorationStyle.font.size = Wt::WFont::Large
  
    top = HangmanDb::getHighScores(20)

    table = Wt::WTable.new(self)
    Wt::WText.new("Rank", table.elementAt(0, 0))
    Wt::WText.new("User", table.elementAt(0, 1))
    Wt::WText.new("Games", table.elementAt(0, 2))
    Wt::WText.new("Score", table.elementAt(0, 3))
    Wt::WText.new("Last game", table.elementAt(0, 4))
    for i in 0...top.size
      Wt::WText.new((i + 1).to_s, table.elementAt(i + 1, 0))
      Wt::WText.new(top[i].user, table.elementAt(i + 1, 1))
      Wt::WText.new(top[i].numgames.to_s, table.elementAt(i+ 1, 2))
      Wt::WText.new(top[i].score.to_s, table.elementAt(i + 1, 3))
      Wt::WText.new(top[i].lastseen.to_s, table.elementAt(i + 1, 4))
    end

    table.resize(Wt::WLength.new(60, Wt::WLength::FontEx), Wt::WLength.new)
    table.setMargin(Wt::WLength.new(20), Wt::Top | Wt::Bottom)
    table.decorationStyle.border = Wt::WBorder.new(Wt::WBorder::Solid)
  
    #
    # Apply cell styles
    #
    for row in 0...table.numRows
      for col in 0...table.numColumns
        cell = table.elementAt(row, col)
        cell.contentAlignment = Wt::AlignMiddle | Wt::AlignCenter
  
        if row == 0
          cell.styleClass = "highscoresheader"
        end

        if row == s
          cell.styleClass = "highscoresself"
        end
      end
    end

    fineprint = Wt::WText.new(  "<p>For each game won, you gain 20 points, " \
                                "minus one point for each wrong letter guess.<br />" \
                                "For each game lost, you lose 10 points, so you " \
                                "better try hard to guess the word!</p>", self )
    fineprint.decorationStyle.font.size = Wt::WFont::Smaller
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

#==============================================================================
# ** Window_Gold
#------------------------------------------------------------------------------
#  This window displays amount of gold.
#==============================================================================

class Window_Gold < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 160, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    icon = RPG::Cache.icon("032-Item01")
    self.contents.blt(4, 4, icon, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(36, 0, self.contents.width - 40, 32, $game_party.gold.to_s, 2)
  end
end
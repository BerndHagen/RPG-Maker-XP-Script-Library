#==============================================================================
# ** Window_Steps
#------------------------------------------------------------------------------
#  This window displays step count on the menu screen.
#==============================================================================

class Window_Steps < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 160, 96)
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, self.contents.width, 32, "Step Count", 0)
    icon = RPG::Cache.icon("020-Accessory05")
    self.contents.blt(4, 36, icon, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(36, 32, self.contents.width - 40, 32, $game_party.steps.to_s, 2)
  end
end
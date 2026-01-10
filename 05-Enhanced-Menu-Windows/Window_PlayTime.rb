#==============================================================================
# ** Window_PlayTime
#------------------------------------------------------------------------------
#  This window displays play time on the menu screen.
#==============================================================================

class Window_PlayTime < Window_Base
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
    self.contents.draw_text(0, 0, self.contents.width, 32, "Play Time", 0)
    icon = RPG::Cache.icon("016-Accessory01")
    self.contents.blt(4, 36, icon, Rect.new(0, 0, 24, 24))
    @total_sec = Graphics.frame_count / Graphics.frame_rate
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    text = sprintf("%02d:%02d", hour, min)
    self.contents.font.color = normal_color
    self.contents.draw_text(36, 32, self.contents.width - 40, 32, text, 2)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if Graphics.frame_count / Graphics.frame_rate != @total_sec
      refresh
    end
  end
end
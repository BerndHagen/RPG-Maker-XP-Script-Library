#==============================================================================
# ** Sprite_Timer
#------------------------------------------------------------------------------
#  This sprite displays the timer with standard RPG Maker window design.
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    @window_sprite = Window.new
    @window_sprite.windowskin = RPG::Cache.windowskin($data_system.windowskin_name)
    @window_sprite.x = 494
    @window_sprite.y = 16
    @window_sprite.width = 130
    @window_sprite.height = 55
    @window_sprite.z = 490
    @window_sprite.contents = Bitmap.new(98, 23)
    @window_sprite.opacity = 255
    @window_sprite.back_opacity = 200
    
    self.bitmap = Bitmap.new(98, 23)
    self.bitmap.font.name = "Arial"
    self.bitmap.font.size = 22
    self.bitmap.font.bold = true
    self.x = 510
    self.y = 32
    self.z = 500
    
    @total_sec = -1
    @last_frame = -1
    @last_second = -1
    @pulse_timer = 0
    @warning_mode = false
    @timer_finished = false
    
    update
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    if @window_sprite != nil
      @window_sprite.contents.dispose if @window_sprite.contents
      @window_sprite.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    current_frame = $game_system.timer
    current_sec = current_frame / Graphics.frame_rate
    if $game_system.timer_working && current_sec == 0 && !@timer_finished
      @timer_finished = true
      begin
        Audio.se_play("Audio/SE/057-Wrong01", 80, 100)
      rescue
        begin
          Audio.se_play("Audio/SE/003-System03", 80, 100)
        rescue
        end
      end
    end
    
    if current_sec > 0
      @timer_finished = false
    end
    
    visible = $game_system.timer_working && current_sec > 0
    self.visible = visible
    @window_sprite.visible = visible
    
    return unless visible
    
    if current_sec != @last_second && current_sec > 0 && @last_second >= 0
      begin
        Audio.se_play("Audio/SE/032-Switch01", 60, 100)
      rescue
        begin
          Audio.se_play("Audio/SE/001-System01", 40, 120)
        rescue
        end
      end
      @last_second = current_sec
    elsif @last_second == -1
      @last_second = current_sec
    end
    
    if current_sec != @total_sec
      @total_sec = current_sec
      redraw_timer
    end
    
    if current_sec <= 10 && current_sec > 0
      @warning_mode = true
      @pulse_timer += 1
      update_warning_effects
    else
      @warning_mode = false
      @window_sprite.opacity = 255
    end
  end
  #--------------------------------------------------------------------------
  # * Redraw Timer
  #--------------------------------------------------------------------------
  def redraw_timer
    self.bitmap.clear
    
    total_frames = $game_system.timer
    total_seconds = total_frames / Graphics.frame_rate
    
    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60
    
    if hours > 0
      time_string = sprintf("%02d:%02d:%02d", hours, minutes, seconds)
    else
      time_string = sprintf("%02d:%02d", minutes, seconds)
    end
    
    if @warning_mode
      pulse_alpha = 128 + (Math.sin(@pulse_timer * 0.3) * 127).to_i
      time_color = Color.new(255, pulse_alpha / 2, pulse_alpha / 2, 255)
    elsif total_seconds <= 30
      time_color = Color.new(255, 255, 100, 255)
    else
      time_color = Color.new(255, 255, 255, 255)
    end
    
    self.bitmap.font.size = 22
    self.bitmap.font.bold = true
    self.bitmap.font.color = time_color
    self.bitmap.draw_text(0, 0, 98, 23, time_string, 1)
  end
  #--------------------------------------------------------------------------
  # * Update Warning Effects
  #--------------------------------------------------------------------------
  def update_warning_effects
    if (@pulse_timer / 30) % 2 == 0
      @window_sprite.opacity = 255
    else
      @window_sprite.opacity = 180
    end
    
    if $game_system.timer / Graphics.frame_rate <= 5
      shake_x = rand(3) - 1
      shake_y = rand(3) - 1
      @window_sprite.x = 494 + shake_x
      @window_sprite.y = 16 + shake_y
      self.x = 510 + shake_x
      self.y = 32 + shake_y
    else
      @window_sprite.x = 494
      @window_sprite.y = 16
      self.x = 510
      self.y = 32
    end
  end
end
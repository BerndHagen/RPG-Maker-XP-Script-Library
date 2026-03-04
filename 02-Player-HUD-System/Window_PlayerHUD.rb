#==============================================================================
# ** Window_PlayerHUD
#------------------------------------------------------------------------------
#  This window displays player information as a HUD overlay for one party member.
#==============================================================================

class Window_PlayerHUD < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor_index, total_actors)
    @actor_index = actor_index
    @total_actors = total_actors
    
    screen_width = 640
    screen_height = 480
    box_width = screen_width / 4
    x_position = actor_index * box_width
    y_position = screen_height - 92
    
    super(x_position, y_position, box_width, 92)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = "Arial"
    self.contents.font.size = 16
    self.opacity = 200
    self.back_opacity = 160
    self.z = 50
    @last_update = Graphics.frame_count
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Get Actor
  #--------------------------------------------------------------------------
  def actor
    return nil if @actor_index >= $game_party.actors.size
    return $game_party.actors[@actor_index]
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if actor.nil?
    
    available_width = self.width - 56
    bar_width = available_width

    self.contents.font.color = normal_color
    self.contents.font.size = 14
    self.contents.font.bold = true
    
    actor_name = actor.name.length > 10 ? actor.name[0,10] + "..." : actor.name
    self.contents.draw_text(2, 0, self.width - 60, 16, actor_name, 0)

    level_text = "Lv #{actor.level}"
    self.contents.draw_text(2, 0, self.width - 36, 16, level_text, 2)
    
    self.contents.font.bold = false
    self.contents.font.size = 16
    
    draw_stat_bar(actor.hp, actor.maxhp, 2, 20, "HP", Color.new(220, 60, 60), bar_width)
    draw_stat_bar(actor.sp, actor.maxsp, 2, 42, "SP", Color.new(60, 60, 220), bar_width)
  end
  
  #--------------------------------------------------------------------------
  # * Draw Stat Bar
  #--------------------------------------------------------------------------
  def draw_stat_bar(current, max, x, y, label, color, bar_width)
    bar_height = 14
    
    self.contents.font.color = system_color
    self.contents.font.size = 12
    self.contents.draw_text(x, y, 20, 16, label)

    bar_x = x + 22
    self.contents.fill_rect(bar_x, y + 2, bar_width, bar_height, Color.new(0, 0, 0, 180))
    self.contents.fill_rect(bar_x + 1, y + 3, bar_width - 2, bar_height - 2, Color.new(40, 40, 40, 180))
    
    percentage = max > 0 ? current.to_f / max.to_f : 0
    fill_width = (bar_width - 4) * percentage

    if fill_width > 0
      draw_gradient_bar(bar_x + 2, y + 4, fill_width.to_i, bar_height - 4, color)
    end
    
    self.contents.fill_rect(bar_x, y + 2, bar_width, 1, Color.new(100, 100, 100, 150))
    self.contents.fill_rect(bar_x, y + 2, 1, bar_height, Color.new(100, 100, 100, 150))
    self.contents.fill_rect(bar_x, y + 2 + bar_height - 1, bar_width, 1, Color.new(100, 100, 100, 150))
    self.contents.fill_rect(bar_x + bar_width - 1, y + 2, 1, bar_height, Color.new(100, 100, 100, 150))
    
    self.contents.font.color = normal_color
    self.contents.font.size = 12
    value_text = "#{current} / #{max}"
    text_width = self.contents.text_size(value_text).width
    text_x = bar_x + (bar_width - text_width) / 2
    self.contents.font.color = Color.new(255, 255, 255, 255)
    self.contents.draw_text(text_x, y + 2, text_width, 14, value_text)
    self.contents.font.size = 16
  end
  
  #--------------------------------------------------------------------------
  # * Draw Gradient Bar
  #--------------------------------------------------------------------------
  def draw_gradient_bar(x, y, width, height, base_color)
    for i in 0...height
      alpha_factor = 1.0 - (i.to_f / height.to_f * 0.3)
      brightness = i < height / 2 ? 1.2 : 0.8
      
      color = Color.new(
        [(base_color.red * brightness * alpha_factor).to_i, 255].min,
        [(base_color.green * brightness * alpha_factor).to_i, 255].min,
        [(base_color.blue * brightness * alpha_factor).to_i, 255].min,
        255
      )
      
      self.contents.fill_rect(x, y + i, width, 1, color)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw Max Level Indicator
  #--------------------------------------------------------------------------
  def draw_max_level_indicator(x, y, bar_width)
    self.contents.font.color = system_color
    self.contents.font.size = 12
    self.contents.draw_text(x, y, 20, 16, "XP")
    self.contents.font.color = Color.new(255, 215, 0)
    self.contents.font.bold = true
    max_text = "MAX"
    self.contents.draw_text(x + 22, y + 2, bar_width, 16, max_text, 1)
    self.contents.font.bold = false
    self.contents.font.size = 16
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    self.z = 50
    if Graphics.frame_count - @last_update > 5
      refresh
      @last_update = Graphics.frame_count
    end
  end
end

class HUD_Manager
  @@hud_windows = []
  
  #--------------------------------------------------------------------------
  # * Show HUD
  #--------------------------------------------------------------------------
  def self.show_hud
    hide_hud
    return if $game_party.nil? || $game_party.actors.empty?
    
    $game_temp = Game_Temp.new if $game_temp == nil
    party_size = [$game_party.actors.size, 4].min
    
    for i in 0...party_size
      hud_window = Window_PlayerHUD.new(i, party_size)
      @@hud_windows.push(hud_window)
    end
    
    $game_temp.hud_windows = @@hud_windows
  end
  
  #--------------------------------------------------------------------------
  # * Hide HUD
  #--------------------------------------------------------------------------
  def self.hide_hud
    @@hud_windows.each do |window|
      window.dispose if window && !window.disposed?
    end
    @@hud_windows.clear
    
    if $game_temp != nil && $game_temp.respond_to?(:hud_windows)
      $game_temp.hud_windows = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # * Toggle HUD
  #--------------------------------------------------------------------------
  def self.toggle_hud
    if @@hud_windows.empty?
      show_hud
    else
      hide_hud
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update HUD
  #--------------------------------------------------------------------------
  def self.update_hud
    @@hud_windows.each do |window|
      window.update if window && !window.disposed?
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh HUD
  #--------------------------------------------------------------------------
  def self.refresh_hud
    current_party_size = [$game_party.actors.size, 4].min
    
    if @@hud_windows.size != current_party_size
      show_hud
    else
      @@hud_windows.each do |window|
        window.refresh if window && !window.disposed?
      end
    end
  end
end

class Game_Temp
  attr_accessor :hud_windows
  
  alias hud_initialize initialize if method_defined?(:initialize)
  def initialize
    if respond_to?(:hud_initialize)
      hud_initialize
    else
      @map_bgm = nil
      @message_text = nil
      @message_proc = nil
      @choice_start = 99
      @choice_max = 0
      @choice_cancel_type = 0
      @choice_proc = nil
      @num_input_start = 99
      @num_input_variable_id = 0
      @num_input_digits_max = 0
      @message_window_showing = false
      @common_event_id = 0
      @in_battle = false
      @battle_calling = false
      @battle_troop_id = 1
      @battle_can_escape = false
      @battle_can_lose = false
      @battle_proc = nil
      @battle_turn = 0
      @battle_event_flags = {}
      @battle_abort = false
      @battle_main_phase = false
      @battleback_name = ''
      @battle_end_status = 0
      @save_calling = false
      @debug_calling = false
      @player_transferring = false
      @player_new_map_id = 0
      @player_new_x = 0
      @player_new_y = 0
      @player_new_direction = 0
      @transition_processing = false
      @transition_name = ""
      @gameover = false
      @to_title = false
      @last_file_index = 0
      @menu_calling = false
      @menu_beep = false
    end
    @hud_windows = nil
  end
end

class Scene_Map
  if method_defined?(:update)
    alias hud_update update
    def update
      hud_update
      HUD_Manager.update_hud
    end
  else
    def update
      super if defined?(super)
      HUD_Manager.update_hud
    end
  end
  if method_defined?(:terminate)
    alias hud_terminate terminate
    def terminate
      HUD_Manager.hide_hud
      hud_terminate
    end
  else
    def terminate
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
  if method_defined?(:main)
    alias hud_main main
    def main
      hud_main
      HUD_Manager.show_hud if $game_party && !$game_party.actors.empty?
    end
  else
    def main
      super if defined?(super)
      HUD_Manager.show_hud if $game_party && !$game_party.actors.empty?
    end
  end
end

class Scene_Title
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Scene_Battle
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
  
  if method_defined?(:battle_end)
    alias hud_battle_end battle_end
    def battle_end(result)
      hud_battle_end(result)
      HUD_Manager.show_hud if $game_party && !$game_party.actors.empty?
    end
  end
end

class Scene_Menu
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
      HUD_Manager.show_hud if $game_party && !$game_party.actors.empty?
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
      HUD_Manager.show_hud if $game_party && !$game_party.actors.empty?
    end
  end
end

class Scene_Save
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Scene_End
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Scene_Item
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Scene_Skill
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Scene_Equip
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Scene_Status
  if method_defined?(:main)
    alias hud_main main
    def main
      HUD_Manager.hide_hud
      hud_main
    end
  else
    def main
      HUD_Manager.hide_hud
      super if defined?(super)
    end
  end
end

class Game_Party
  if method_defined?(:add_actor)
    alias hud_add_actor add_actor
    def add_actor(actor_id)
      hud_add_actor(actor_id)
      HUD_Manager.refresh_hud
    end
  end
  if method_defined?(:remove_actor)
    alias hud_remove_actor remove_actor
    def remove_actor(actor_id)
      hud_remove_actor(actor_id)
      HUD_Manager.refresh_hud
    end
  end
end
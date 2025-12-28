#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class adds bestiary tracking to the game system.
#==============================================================================
class Game_System
  attr_accessor :bestiary
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias bestiary_initialize initialize
  def initialize
    bestiary_initialize
    @bestiary = {}
  end
  
  #--------------------------------------------------------------------------
  # * Register Enemy
  #--------------------------------------------------------------------------
  def register_enemy(enemy_id)
    @bestiary[enemy_id] = true
  end
  
  #--------------------------------------------------------------------------
  # * Enemy Discovered?
  #--------------------------------------------------------------------------
  def enemy_discovered?(enemy_id)
    return @bestiary[enemy_id] == true
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class registers defeated enemies in the bestiary.
#==============================================================================
class Scene_Battle
  alias bestiary_start_phase5 start_phase5
  def start_phase5
    for enemy in $game_troop.enemies
      unless enemy.hidden
        $game_system.register_enemy(enemy.id)
      end
    end
    bestiary_start_phase5
  end
end

#==============================================================================
# ** Window_BestiaryList
#------------------------------------------------------------------------------
#  This window displays the list of all monsters.
#==============================================================================
class Window_BestiaryList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 64, 240, 416)
    @column_max = 1
    self.index = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Get Enemy
  #--------------------------------------------------------------------------
  def enemy
    return @data[self.index]
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    
    for i in 1...$data_enemies.size
      if $data_enemies[i] != nil
        @data.push($data_enemies[i])
      end
    end
    
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    enemy = @data[index]
    x = 4
    y = index * 32
    
    if $game_system.enemy_discovered?(enemy.id)
      number = sprintf("%03d", enemy.id)
      self.contents.font.color = normal_color
      self.contents.draw_text(x, y, 200, 32, number + " - " + enemy.name)
    else
      self.contents.font.color = disabled_color
      self.contents.draw_text(x, y, 200, 32, "???")
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Help
  #--------------------------------------------------------------------------
  def update_help
    if self.enemy == nil
      @help_window.set_text("")
    else
      if $game_system.enemy_discovered?(self.enemy.id)
        rewards_text = "Rewards: " + self.enemy.gold.to_s + " Gold, " + self.enemy.exp.to_s + " EXP"
        @help_window.set_text(rewards_text)
      else
        @help_window.set_text("???")
      end
    end
  end
end

#==============================================================================
# ** Window_BestiaryName
#------------------------------------------------------------------------------
#  This window displays the monster's name above the image.
#==============================================================================
class Window_BestiaryName < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(240, 64, 400, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @enemy = nil
  end
  
  #--------------------------------------------------------------------------
  # * Set Enemy
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    if @enemy != enemy
      @enemy = enemy
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if @enemy == nil
    
    if $game_system.enemy_discovered?(@enemy.id)
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, 360, 32, @enemy.name, 1)
    else
      self.contents.font.color = crisis_color
      self.contents.draw_text(4, 0, 360, 32, "???", 1)
    end
  end
end

#==============================================================================
# ** Window_BestiaryImage
#------------------------------------------------------------------------------
#  This window displays the monster's image or silhouette.
#==============================================================================
class Window_BestiaryImage < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(240, 128, 400, 200)
    self.contents = Bitmap.new(width - 32, height - 32)
    @enemy = nil
  end
  
  #--------------------------------------------------------------------------
  # * Set Enemy
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    if @enemy != enemy
      @enemy = enemy
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if @enemy == nil
    
    discovered = $game_system.enemy_discovered?(@enemy.id)
    
    if @enemy.battler_name != ""
      bitmap = RPG::Cache.battler(@enemy.battler_name, @enemy.battler_hue)
      
      max_width = 360
      max_height = 168
      scale = 1.0
      
      if bitmap.width > max_width or bitmap.height > max_height
        scale_x = max_width.to_f / bitmap.width
        scale_y = max_height.to_f / bitmap.height
        scale = [scale_x, scale_y].min
      end
      
      new_width = (bitmap.width * scale).to_i
      new_height = (bitmap.height * scale).to_i
      
      x = 184 - new_width / 2
      y = 84 - new_height / 2
      
      dest_rect = Rect.new(x, y, new_width, new_height)
      src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      
      if discovered
        self.contents.stretch_blt(dest_rect, bitmap, src_rect)
      else
        silhouette = Bitmap.new(bitmap.width, bitmap.height)
        for i in 0...bitmap.width
          for j in 0...bitmap.height
            color = bitmap.get_pixel(i, j)
            if color.alpha > 0
              silhouette.set_pixel(i, j, Color.new(0, 0, 0, 255))
            end
          end
        end
        self.contents.stretch_blt(dest_rect, silhouette, src_rect, 128)
        silhouette.dispose
      end
    end
  end
end

#==============================================================================
# ** Window_BestiaryStats
#------------------------------------------------------------------------------
#  This window displays the monster's combat stats.
#==============================================================================
class Window_BestiaryStats < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(240, 328, 200, 152)
    self.contents = Bitmap.new(width - 32, height - 32)
    @enemy = nil
  end
  
  #--------------------------------------------------------------------------
  # * Set Enemy
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    if @enemy != enemy
      @enemy = enemy
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if @enemy == nil
    
    discovered = $game_system.enemy_discovered?(@enemy.id)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 60, 32, "HP:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.maxhp.to_s : "???"
    self.contents.draw_text(64, 0, 100, 32, value, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 24, 60, 32, "SP:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.maxsp.to_s : "???"
    self.contents.draw_text(64, 24, 100, 32, value, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 48, 60, 32, "ATK:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.atk.to_s : "???"
    self.contents.draw_text(64, 48, 100, 32, value, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 72, 60, 32, "DEF:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.pdef.to_s : "???"
    self.contents.draw_text(64, 72, 100, 32, value, 2)
  end
end

#==============================================================================
# ** Window_BestiaryStats2
#------------------------------------------------------------------------------
#  This window displays additional combat stats.
#==============================================================================
class Window_BestiaryStats2 < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(440, 328, 200, 152)
    self.contents = Bitmap.new(width - 32, height - 32)
    @enemy = nil
  end
  
  #--------------------------------------------------------------------------
  # * Set Enemy
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    if @enemy != enemy
      @enemy = enemy
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if @enemy == nil
    
    discovered = $game_system.enemy_discovered?(@enemy.id)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 60, 32, "MDEF:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.mdef.to_s : "???"
    self.contents.draw_text(64, 0, 100, 32, value, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 24, 60, 32, "AGI:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.agi.to_s : "???"
    self.contents.draw_text(64, 24, 100, 32, value, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 48, 60, 32, "EVA:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.eva.to_s + "%" : "???"
    self.contents.draw_text(64, 48, 100, 32, value, 2)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 72, 60, 32, "EXP:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.exp.to_s : "???"
    self.contents.draw_text(64, 72, 100, 32, value, 2)
  end
end

#==============================================================================
# ** Window_BestiaryRewards
#------------------------------------------------------------------------------
#  This window displays rewards (gold and items).
#==============================================================================
class Window_BestiaryRewards < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(240, 480, 400, 80)
    self.contents = Bitmap.new(width - 32, height - 32)
    @enemy = nil
  end
  
  #--------------------------------------------------------------------------
  # * Set Enemy
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    if @enemy != enemy
      @enemy = enemy
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    return if @enemy == nil
    
    discovered = $game_system.enemy_discovered?(@enemy.id)
    
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 60, 32, "Gold:")
    self.contents.font.color = discovered ? normal_color : disabled_color
    value = discovered ? @enemy.gold.to_s : "???"
    self.contents.draw_text(64, 0, 100, 32, value, 2)
    
    if discovered
      if @enemy.item_id > 0
        item = $data_items[@enemy.item_id]
        self.contents.font.color = system_color
        self.contents.draw_text(180, 0, 60, 32, "Drop:")
        self.contents.font.color = normal_color
        self.contents.draw_text(240, 0, 120, 32, item.name)
      elsif @enemy.weapon_id > 0
        weapon = $data_weapons[@enemy.weapon_id]
        self.contents.font.color = system_color
        self.contents.draw_text(180, 0, 60, 32, "Drop:")
        self.contents.font.color = normal_color
        self.contents.draw_text(240, 0, 120, 32, weapon.name)
      elsif @enemy.armor_id > 0
        armor = $data_armors[@enemy.armor_id]
        self.contents.font.color = system_color
        self.contents.draw_text(180, 0, 60, 32, "Drop:")
        self.contents.font.color = normal_color
        self.contents.draw_text(240, 0, 120, 32, armor.name)
      end
    else
      self.contents.font.color = system_color
      self.contents.draw_text(180, 0, 60, 32, "Drop:")
      self.contents.font.color = disabled_color
      self.contents.draw_text(240, 0, 120, 32, "???")
    end
  end
end

#==============================================================================
# ** Scene_Bestiary
#------------------------------------------------------------------------------
#  This class performs bestiary menu processing.
#==============================================================================
class Scene_Bestiary
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    @help_window = Window_Help.new
    @help_window.set_text("Bestiary")
    
    @list_window = Window_BestiaryList.new
    @list_window.help_window = @help_window
    
    @name_window = Window_BestiaryName.new
    @image_window = Window_BestiaryImage.new
    @stats_window = Window_BestiaryStats.new
    @stats2_window = Window_BestiaryStats2.new
    @rewards_window = Window_BestiaryRewards.new
    
    @name_window.set_enemy(@list_window.enemy)
    @image_window.set_enemy(@list_window.enemy)
    @stats_window.set_enemy(@list_window.enemy)
    @stats2_window.set_enemy(@list_window.enemy)
    @rewards_window.set_enemy(@list_window.enemy)
    
    [@help_window, @list_window, @name_window, @image_window, @stats_window, @stats2_window, @rewards_window].each do |window|
      window.opacity = 210
      window.back_opacity = 170
    end
    
    @map_sprite = Spriteset_Map.new
    
    Graphics.transition
    
    loop do
      Graphics.update
      Input.update
      @map_sprite.update
      update
      break if $scene != self
    end
    
    Graphics.freeze
    @map_sprite.dispose
    
    @help_window.dispose
    @list_window.dispose
    @name_window.dispose
    @image_window.dispose
    @stats_window.dispose
    @stats2_window.dispose
    @rewards_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @help_window.update
    @list_window.update
    @name_window.update
    @image_window.update
    @stats_window.update
    @stats2_window.update
    @rewards_window.update
    
    if @list_window.active
      update_list
    end
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update (when list window is active)
  #--------------------------------------------------------------------------
  def update_list
    @name_window.set_enemy(@list_window.enemy)
    @image_window.set_enemy(@list_window.enemy)
    @stats_window.set_enemy(@list_window.enemy)
    @stats2_window.set_enemy(@list_window.enemy)
    @rewards_window.set_enemy(@list_window.enemy)
    
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(0)
      return
    end
  end
end

#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class adds bestiary option to the menu (optional).
#==============================================================================
class Scene_Menu
  alias bestiary_update_command update_command
  #--------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #--------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::R)
      $game_system.se_play($data_system.decision_se)
      $scene = Scene_Bestiary.new
      return
    end
    bestiary_update_command
  end
end


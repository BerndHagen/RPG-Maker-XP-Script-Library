#==============================================================================
# ** Item Popup System
#------------------------------------------------------------------------------
#  Standard RPG Maker XP window-based popup for obtained items.
#  Windows slide in from the right edge of the screen and stack vertically.
#
#  Usage in Event Script:
#    $game_party.item_popup(item_id, amount)     # For items
#    $game_party.weapon_popup(weapon_id, amount) # For weapons
#    $game_party.armor_popup(armor_id, amount)   # For armor
#    $game_party.gold_popup(amount)              # For gold
#
#  Example:
#    $game_party.item_popup(1, 2)   # Shows "[Icon] Potion       x 2"
#    $game_party.weapon_popup(1, 1) # Shows "[Icon] Bronze Sword x 1"
#    $game_party.gold_popup(500)    # Shows "[Icon] Gold         x 500"
#==============================================================================

#==============================================================================
# ** Window_ItemPopup
#------------------------------------------------------------------------------
#  A standard RPG Maker XP window for item popups
#==============================================================================
class Window_ItemPopup < Window_Base
  #--------------------------------------------------------------------------
  # * Configuration
  #--------------------------------------------------------------------------
  DISPLAY_TIME = 120                  # Frames to display (2 seconds at 60fps)
  SLIDE_IN_TIME = 12                  # Frames for slide-in animation
  SLIDE_OUT_TIME = 12                 # Frames for slide-out animation
  SOUND_EFFECT = "002-System02"       # Sound when popup appears
  WINDOW_WIDTH = 260                  # Width of popup window
  WINDOW_HEIGHT = 52                  # Height of popup window (compact but fits content)
  OVERHANG = 32                       # How much window hangs off right edge
  MARGIN_BOTTOM = 8                   # Margin from bottom edge
  STACK_SPACING = 4                   # Space between stacked popups
  GOLD_ICON = "032-Item01"            # Icon for gold popup
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(stack_index = 0)
    @stack_index = stack_index
    super(640, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z = 9999
    @timer = 0
    @phase = :hidden
    update_target_position
  end
  
  #--------------------------------------------------------------------------
  # * Update Target Position Based on Stack Index
  #--------------------------------------------------------------------------
  def update_target_position
    @target_x = 640 - WINDOW_WIDTH + OVERHANG
    @target_y = 480 - WINDOW_HEIGHT - MARGIN_BOTTOM - (@stack_index * (WINDOW_HEIGHT + STACK_SPACING))
  end
  
  #--------------------------------------------------------------------------
  # * Set Stack Index
  #--------------------------------------------------------------------------
  def stack_index=(value)
    @stack_index = value
    update_target_position
    if @phase == :displayed || @phase == :sliding_in
      self.y = @target_y
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Stack Index
  #--------------------------------------------------------------------------
  def stack_index
    @stack_index
  end
  
  #--------------------------------------------------------------------------
  # * Display Popup
  #--------------------------------------------------------------------------
  def display_popup(name, icon_name, amount, play_sound = true)
    if play_sound
      se = RPG::AudioFile.new(SOUND_EFFECT, 80, 100)
      $game_system.se_play(se)
    end
    self.contents.clear
    icon_bitmap = nil
    if icon_name != "" && icon_name != "gold"
      begin
        icon_bitmap = RPG::Cache.icon(icon_name)
      rescue
        icon_bitmap = nil
      end
    elsif icon_name == "gold"
      begin
        icon_bitmap = RPG::Cache.icon(GOLD_ICON)
      rescue
        icon_bitmap = nil
      end
    end
    content_height = WINDOW_HEIGHT - 32
    icon_x = 0
    icon_y = (content_height - 24) / 2
    
    if icon_bitmap
      self.contents.blt(icon_x, icon_y, icon_bitmap, Rect.new(0, 0, 24, 24))
    end
    text_x = icon_x + 32
    text_y = (content_height - 16) / 2 - 1
    self.contents.font.size = 18
    self.contents.font.bold = true
    self.contents.font.color = normal_color
    self.contents.draw_text(text_x, text_y, 110, 18, name)
    if amount > 0
      self.contents.font.color = system_color
      amount_text = "x #{amount}"
      self.contents.draw_text(WINDOW_WIDTH - 32 - OVERHANG - 60, text_y, 60, 18, amount_text, 2)
    end
    self.contents.font.bold = false
    @timer = 0
    @phase = :sliding_in
    update_target_position
    self.x = 640
    self.y = @target_y
    self.visible = true
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    
    case @phase
    when :sliding_in
      @timer += 1
      progress = [@timer.to_f / SLIDE_IN_TIME.to_f, 1.0].min
      ease_progress = 1.0 - (1.0 - progress) ** 2
      self.x = 640 - ((640 - @target_x) * ease_progress).to_i
      
      if @timer >= SLIDE_IN_TIME
        @phase = :displayed
        @timer = 0
        self.x = @target_x
      end
      
    when :displayed
      self.y = @target_y
      @timer += 1
      if @timer >= DISPLAY_TIME
        @phase = :sliding_out
        @timer = 0
      end
      
    when :sliding_out
      @timer += 1
      progress = [@timer.to_f / SLIDE_OUT_TIME.to_f, 1.0].min
      ease_progress = progress ** 2
      self.x = @target_x + ((640 - @target_x) * ease_progress).to_i
      
      if @timer >= SLIDE_OUT_TIME
        @phase = :hidden
        @timer = 0
        self.visible = false
        self.x = 640
      end
      
    when :hidden
      self.visible = false
    end
  end
  
  #--------------------------------------------------------------------------
  # * Check if Active
  #--------------------------------------------------------------------------
  def active?
    @phase != :hidden
  end
  
  #--------------------------------------------------------------------------
  # * Check if Ready for Reuse
  #--------------------------------------------------------------------------
  def available?
    @phase == :hidden
  end
end

#==============================================================================
# ** ItemPopupManager
#------------------------------------------------------------------------------
#  Manages multiple stacked item popup windows
#==============================================================================
class ItemPopupManager
  MAX_POPUPS = 5  # Maximum simultaneous popups
  
  def initialize
    @popups = []
    MAX_POPUPS.times do |i|
      @popups << Window_ItemPopup.new(i)
    end
  end
  
  def show_item(item_id, amount = 1)
    item = $data_items[item_id]
    return unless item
    $game_party.gain_item(item_id, amount)
    add_popup(item.name, item.icon_name, amount)
  end
  
  def show_weapon(weapon_id, amount = 1)
    weapon = $data_weapons[weapon_id]
    return unless weapon
    $game_party.gain_weapon(weapon_id, amount)
    add_popup(weapon.name, weapon.icon_name, amount)
  end
  
  def show_armor(armor_id, amount = 1)
    armor = $data_armors[armor_id]
    return unless armor
    $game_party.gain_armor(armor_id, amount)
    add_popup(armor.name, armor.icon_name, amount)
  end
  
  def show_gold(amount)
    return if amount <= 0
    $game_party.gain_gold(amount)
    add_popup("Gold", "gold", amount)
  end
  
  def add_popup(name, icon_name, amount)
    @popups.each do |popup|
      if popup.active?
        popup.stack_index += 1
      end
    end
    available_popup = @popups.find { |p| p.available? }
    
    if available_popup
      available_popup.stack_index = 0
      available_popup.display_popup(name, icon_name, amount)
    end
  end
  
  def update
    @popups.each { |popup| popup.update }
    reindex_popups
  end
  
  def reindex_popups
    active = @popups.select { |p| p.active? }.sort_by { |p| p.stack_index }
    active.each_with_index do |popup, index|
      popup.stack_index = index
    end
  end
  
  def dispose
    @popups.each { |popup| popup.dispose }
    @popups.clear
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  Add item popup manager to map scene
#==============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # * Alias: Main Processing
  #--------------------------------------------------------------------------
  alias item_popup_main main unless method_defined?(:item_popup_main)
  def main
    $item_popup_manager = ItemPopupManager.new
    item_popup_main
    $item_popup_manager.dispose
    $item_popup_manager = nil
  end
  
  #--------------------------------------------------------------------------
  # * Alias: Frame Update
  #--------------------------------------------------------------------------
  alias item_popup_update update unless method_defined?(:item_popup_update)
  def update
    $item_popup_manager.update if $item_popup_manager
    item_popup_update
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Add convenience methods to trigger popups from events
#==============================================================================
class Game_Party
  #--------------------------------------------------------------------------
  # * Show Item Popup (call from event)
  #--------------------------------------------------------------------------
  def item_popup(item_id, amount = 1)
    if $item_popup_manager
      $item_popup_manager.show_item(item_id, amount)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Weapon Popup (call from event)
  #--------------------------------------------------------------------------
  def weapon_popup(weapon_id, amount = 1)
    if $item_popup_manager
      $item_popup_manager.show_weapon(weapon_id, amount)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Armor Popup (call from event)
  #--------------------------------------------------------------------------
  def armor_popup(armor_id, amount = 1)
    if $item_popup_manager
      $item_popup_manager.show_armor(armor_id, amount)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Gold Popup (call from event)
  #--------------------------------------------------------------------------
  def gold_popup(amount)
    if $item_popup_manager
      $item_popup_manager.show_gold(amount)
    end
  end
end

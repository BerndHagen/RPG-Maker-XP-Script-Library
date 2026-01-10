#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#  Includes typewriter effect and message history navigation.
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  HISTORY_SOUND = "046-Book01"    # Sound when navigating history
  HISTORY_MAX = 20                # Maximum messages to remember
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(80, 304, 480, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    self.active = false
    self.index = -1
    @typewriter_text = ""
    @typewriter_all_text = ""
    @typewriter_index = 0
    @typewriter_wait = 0
    # Message history
    @message_history = []
    @history_index = -1  # -1 = current message, 0+ = history
    @viewing_history = false
    @is_replay = false   # True if showing already-seen message
  end
  #--------------------------------------------------------------------------
  # * Show History Message (instant display, gray text)
  #--------------------------------------------------------------------------
  def show_history_message(message_text, going_back = true)
    # Play navigation sound
    se = RPG::AudioFile.new(HISTORY_SOUND, 80, 100)
    $game_system.se_play(se)
    @is_replay = true
    @typewriter_all_text = message_text.clone
    @typewriter_text = message_text.clone
    @typewriter_index = message_text.length
    self.pause = true
    refresh
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Terminate Message
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    @contents_showing = false
    # Save message to history (only pure text messages, no choices)
    if @typewriter_all_text != "" and $game_temp.choice_max == 0 and not @viewing_history
      @message_history.push(@typewriter_all_text.clone)
      if @message_history.size > HISTORY_MAX
        @message_history.shift
      end
    end
    @typewriter_text = ""
    @typewriter_all_text = ""
    @typewriter_index = 0
    @typewriter_wait = 0
    @viewing_history = false
    @history_index = -1
    @is_replay = false
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # Use gray color for history/replay messages, normal color otherwise
    if @is_replay
      self.contents.font.color = disabled_color
    else
      self.contents.font.color = normal_color
    end
    x = y = 0
    @cursor_width = 0
    if $game_temp.choice_start == 0
      x = 8
    end
    if $game_temp.message_text != nil
      if @typewriter_all_text == ""
        @typewriter_all_text = $game_temp.message_text.clone
        begin
          last_text = @typewriter_all_text.clone
          @typewriter_all_text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
        end until @typewriter_all_text == last_text
        @typewriter_all_text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
          $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
        end
        @typewriter_all_text.gsub!(/\\\\/) { "\000" }
        @typewriter_all_text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
        @typewriter_all_text.gsub!(/\\[Gg]/) { "\002" }
        @typewriter_index = 0
        @typewriter_text = ""
      end
      
      text = @typewriter_text.clone
      while ((c = text.slice!(/./m)) != nil)
        if c == "\000"
          c = "\\"
        end
        if c == "\001"
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          next
        end
        if c == "\002"
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          next
        end
        if c == "\n"
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          y += 1
          x = 0
          if y >= $game_temp.choice_start
            x = 8
          end
          next
        end
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        x += self.contents.text_size(c).width
      end
    end
    if $game_temp.choice_max > 0 and @typewriter_index >= @typewriter_all_text.length
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    if $game_temp.num_input_variable_id > 0 and @typewriter_index >= @typewriter_all_text.length
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
  #--------------------------------------------------------------------------
  # * Set Window Position and Opacity Level
  #--------------------------------------------------------------------------
  def reset_window
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0
        self.y = 16
      when 1
        self.y = 160
      when 2
        self.y = 304
      end
    end
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    self.back_opacity = 160
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    if @input_number_window != nil
      @input_number_window.update
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    if @contents_showing
      # History navigation with L button (go back)
      if Input.trigger?(Input::L) and $game_temp.choice_max == 0
        if @viewing_history
          # Already in history, go further back
          if @history_index < @message_history.size - 1
            @history_index += 1
            show_history_message(@message_history[@message_history.size - 1 - @history_index], true)
          end
        else
          # Enter history mode
          if @message_history.size > 0
            @viewing_history = true
            @history_index = 0
            @saved_current_message = @typewriter_all_text.clone
            show_history_message(@message_history[@message_history.size - 1], true)
          end
        end
        return
      end
      
      # History navigation with R button (go forward)
      if Input.trigger?(Input::R) and @viewing_history
        if @history_index > 0
          # Go forward in history
          @history_index -= 1
          @is_replay = true
          show_history_message(@message_history[@message_history.size - 1 - @history_index], false)
        else
          # Return to current message
          @viewing_history = false
          @history_index = -1
          @is_replay = false
          @typewriter_all_text = @saved_current_message.clone
          @typewriter_text = @typewriter_all_text.clone
          @typewriter_index = @typewriter_all_text.length
          se = RPG::AudioFile.new(HISTORY_SOUND, 80, 100)
          $game_system.se_play(se)
          refresh
        end
        return
      end
      
      if @typewriter_index < @typewriter_all_text.length
        @typewriter_wait -= 1
        if @typewriter_wait <= 0
          char = @typewriter_all_text[@typewriter_index, 1]
          if char
            @typewriter_text += char
            if char != "\000" and char != "\001" and char != "\002" and char != "\n" and char != " "
              $game_system.se_play($data_system.cursor_se)
            end
          end
          @typewriter_index += 1
          @typewriter_wait = 1
          refresh
        end
      end
      
      if $game_temp.choice_max == 0 and @typewriter_index >= @typewriter_all_text.length
        self.pause = true
      end

      if Input.trigger?(Input::B)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        end
      end

      if Input.trigger?(Input::C)
        # If viewing history, return to current message instead of advancing
        if @viewing_history
          @viewing_history = false
          @history_index = -1
          @is_replay = false
          @typewriter_all_text = @saved_current_message.clone
          @typewriter_text = @typewriter_all_text.clone
          @typewriter_index = @typewriter_all_text.length
          refresh
          return
        end
        if @typewriter_index < @typewriter_all_text.length
          @typewriter_text = @typewriter_all_text.clone
          @typewriter_index = @typewriter_all_text.length
          refresh
          return
        end
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(self.index)
        end
        terminate_message
      end
      return
    end

    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end

    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
end
addpath envs
addpath filters
addpath base

%% ------ CONFIG VARS

fig = figure;
plt = subplot(311);

cur_note = def_note();
cur_time = def_timesig();
cur_track = {[]};%%current track is a cell array of the list of notes
cur_track_num = 1;

track_filter = @(t) t;%filter that covers playback

cur_octave = 4;

%% ------ Keyboard config

%panel for the keys
key_panel = uipanel(fig, ...
    'Position', [0.05 0.35 0.9 0.3]);

cur_keys = 440 * 2.^((cur_octave - 4) + ([1:25] - 10) / 12);

key_press = @(k) strcat('cur_note.freq = cur_keys(',...
    num2str(k),');',...
    ['sound(track_filter(write_note(cur_note, cur_time)));',...
    'cur_track{cur_track_num} = [cur_track{cur_track_num} cur_note];' ...
    'update_plot(cur_track{cur_track_num});']);


w_key = @(pos) ...
    uicontrol(key_panel,...
    'Style', 'pushbutton',...
    'FontUnits', 'normalized',...
    'Units', 'normalized', ...
    'Position', [pos (1/18) 0.9]);

b_key = @(pos) ...
    uicontrol(key_panel,...
    'Style', 'pushbutton',...
    'FontUnits', 'normalized',...
    'Units', 'normalized', ...
    'BackgroundColor', 'black', ...
    'Position', [pos (1/20) 0.45]);

white_keys = [1 3 5 6 8 10 12 13 15 17 18 20 22 24 25];
black_keys = [2 4 7 9 11 14 16 19 21 23];

for ind = 1:length(white_keys)
    h_pos = (1/17) * ind;
    keys(white_keys(ind)) = w_key([h_pos 0.05]);
    keys(white_keys(ind)).Callback = key_press(white_keys(ind));
end

black_key_pos = [2 4 8 10 12 16 18 22 24 26];

for ind = 1:length(black_keys)
    h_pos = (1/34) * black_key_pos(ind) + 1/34;
    keys(black_keys(ind)) = b_key([h_pos 0.45]);
    keys(black_keys(ind)).Callback = key_press(black_keys(ind));
end

% Change octave buttons

l_octave = uicontrol(key_panel,...
    'String', '<',...
    'Style', 'pushbutton',...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0 0.05 (1/18) 0.9],...
    'Callback', 'cur_octave = cur_octave - 1;cur_keys = 440 * 2.^((cur_octave - 4) + ([1:25] - 10) / 12);');

r_octave = uicontrol(key_panel,...
    'String', '>',...
    'Style', 'pushbutton',...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [16/17 0.05 (1/18) 0.9], ...
    'Callback', 'cur_octave = cur_octave + 1;cur_keys = 440 * 2.^((cur_octave - 4) + ([1:25] - 10) / 12);');

%% -------- PLAYBACK PANEL

playback_panel = uipanel(fig, ...
    'Title', 'Playback',...
    'Position', [0.7 0.03 0.25 0.30]);

save_note = uicontrol(playback_panel,...
    'String', 'Save note',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.05 0.825 0.4 0.15], ...
    'Callback', ...
    ['cur_track{cur_track_num} = [cur_track{cur_track_num} cur_note];' ...
    'update_plot(cur_track{cur_track_num});']);

delete_note = uicontrol(playback_panel,...
    'String', 'Delete note',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.5 0.825 0.4 0.15], ...
    'Callback', ...
    ['cur_track{cur_track_num}(end) = [];',...
    'update_plot(cur_track{cur_track_num});']);

play_track = uicontrol(playback_panel,...
    'String', 'Play Current track',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.05 0.625 0.4 0.15], ...
    'Callback', ...
    'sound(track_filter(track_to_sig(cur_track{cur_track_num}, cur_time)));');
    
play_all = uicontrol(playback_panel,...
    'String', 'Play all tracks',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.5 0.625 0.4 0.15], ...
    'Callback', ...
    'sound(track_filter(all_track_to_sig(cur_track, cur_time)));');

add_track = uicontrol(playback_panel,...
    'String', 'Add track',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.05 0.425 0.3 0.15], ...
    'Callback', ...
    ['cur_track_num = length(cur_track) + 1;' ...
    'cur_track{cur_track_num} = [];' ...
    'update_plot(cur_track{cur_track_num});']);

delete_elem = @(carr, ind) carr(1, [[1:ind - 1] [ind+1:end]]);

delete_track = uicontrol(playback_panel,...
    'String', 'Delete track',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.35 0.425 0.3 0.15], ...
    'Callback', ...
    ['cur_track = delete_elem(cur_track, cur_track_num);' ...
    'cur_track_num = 1;',...
    'update_plot(cur_track{cur_track_num});']);

clear_track = uicontrol(playback_panel,...
    'String', 'Clear track',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.65 0.425 0.3 0.15], ...
    'Callback', ...
    ['cur_track{cur_track_num} = [];'...
    'update_plot(cur_track{cur_track_num});']);

track_down = uicontrol(playback_panel,...
    'String', 'Track Down',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.05 0.225 0.4 0.15], ...
    'Callback', ...
    ['cur_track_num = next_effect(length(cur_track), cur_track_num);' ...
    'update_plot(cur_track{cur_track_num});']);

track_up = uicontrol(playback_panel,...
    'String', 'Track Up',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.5 0.225 0.4 0.15], ...
    'Callback', ...
    ['cur_track_num = prev_effect(length(cur_track), cur_track_num);' ...
    'update_plot(cur_track{cur_track_num});']);

name_edit = uicontrol(playback_panel,...
    'String', 'sample.wav',...
    'Style', 'edit',...
    'Units', 'normalized',...
    'Position', [0.05 0.05 0.3 0.10]);

save_all = uicontrol(playback_panel,...
    'String', 'Save All',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.35 0.05 0.3 0.10], ...
    'Callback', ...
    ['audiowrite(''',...
    name_edit.String,...
    ''', track_filter(all_track_to_sig(cur_track, cur_time))',...
    ', 8192);']);

load_track = uicontrol(playback_panel,...
    'String', 'Load File',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.65 0.05 0.3 0.10], ...
    'Callback', ...
    ['cur_track_num = length(cur_track) + 1;',...
    'cur_track{cur_track_num} = transcribe(''',...
    name_edit.String,...
    ''', 8192);',...
    'update_plot(cur_track{cur_track_num});']);

%% -------- NOTE CONFIG PANEL

note_conf_panel = uipanel(fig, ...
    'Title', 'Note config',...
    'Position', [0.4 0.03 0.25 0.30]);

% note length config

note_length_gp = uibuttongroup(note_conf_panel,...
    'Title', 'Beats',...
    'Position', [0.02 0.58 0.96 0.4]);

beat_key_gen = @(pos, dur, cb) uicontrol(note_length_gp,...
    'Style', 'radiobutton', ...
    'String', num2str(dur),...
    'Units', 'normalized',...
    'Position', pos,...
    'Callback', cb);

beat_key(1) = beat_key_gen([0.05 0.65 0.45 0.3], 1,...
    'cur_note.beats = 1;');

beat_key(2) = beat_key_gen([0.05 0.35 0.45 0.3], 1/2,...
    'cur_note.beats = 1/2;');

beat_key(3) = beat_key_gen([0.05 0.05 0.45 0.3], 1/4,...
    'cur_note.beats = 1/4;');

beat_key(4) = beat_key_gen([0.55 0.65 0.45 0.3], 2,...
    'cur_note.beats = 2;');

beat_key(5) = beat_key_gen([0.55 0.35 0.45 0.3], 4,...
    'cur_note.beats = 4;');

% dynamics config

dynamics_title = uicontrol(note_conf_panel,...
    'String', 'Dynamics',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.05 0.48 0.9 0.1]);

dynamics_p = uicontrol(note_conf_panel,...
    'String', 'p',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.05 0.40 0.2 0.1]);

dynamics_m = uicontrol(note_conf_panel,...
    'String', 'm',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.38 0.40 0.2 0.1]);

dynamics_f = uicontrol(note_conf_panel,...
    'String', 'f',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.7 0.40 0.2 0.1]);

dynamics_slider = uicontrol(note_conf_panel,...
    'Style', 'slider',...
    'Units', 'normalized',...
    'Position', [0.05 0.3 0.9 0.1], ...
    'Min', 0,...
    'Max', 1,...
    'Value', 0.5,...
    'Callback', ...
    'cur_note.scale = dynamics_slider.Value;');

% Time sig config

bpm_lab = uicontrol(note_conf_panel,...
    'String', 'bpm',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.15 0.15 0.2 0.1]);

bpm_box = uicontrol(note_conf_panel,...
    'Style', 'edit',...
    'Units', 'normalized',...
    'Position', [0.05 0.05 0.45 0.1],...
    'String', '4',...
    'Callback',...
    'cur_time.bpm = str2num(bpm_box.String);');

tempo_lab = uicontrol(note_conf_panel,...
    'String', 'tempo',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.65 0.15 0.2 0.1]);

tempo_box = uicontrol(note_conf_panel,...
    'Style', 'edit',...
    'Units', 'normalized',...
    'Position', [0.5 0.05 0.45 0.1],...
    'String', '90',...
    'Callback',...
    'cur_time.tempo = str2num(tempo_box.String);');

%% ---------- EFFECTS

effects_panel = uipanel(fig, ...
    'Title', 'Effects',...
    'Position', [0.05 0.03 0.30 0.30]);

%% effects groups

effect_gp(1) = uibuttongroup(effects_panel,...
    'Visible' , 'on',...
    'Title', 'Envelopes',...
    'Position', [0.02 0.02 0.96 0.9]);

effect_gp(2) = uibuttongroup(effects_panel,...
    'Visible' , 'off',...
    'Title', 'ADSR',...
    'Position', [0.02 0.02 0.96 0.9]);

effect_gp(3) = uibuttongroup(effects_panel,...
    'Visible' , 'off',...
    'Title', 'Filters',...
    'Position', [0.02 0.02 0.96 0.9]);

effect_gp(4) = uibuttongroup(effects_panel,...
    'Visible' , 'off',...
    'Title', 'Vibrato',...
    'Position', [0.02 0.02 0.96 0.9]);

effect_gp(5) = uibuttongroup(effects_panel,...
    'Visible' , 'off',...
    'Title', 'FM Modulation Settings',...
    'Position', [0.02 0.02 0.96 0.9]);

effect_gp(6) = uibuttongroup(effects_panel,...
    'Visible' , 'off',...
    'Title', 'Presets',...
    'Position', [0.02 0.02 0.96 0.9]);

total_effects = 6;
cur_effect = 1;
next_effect = @(tot, cur) mod(cur, tot) + 1;
prev_effect = @(tot, cur) mod(cur - 2, tot) + 1;

next_effect_but = uicontrol(effects_panel,...
    'String', '>',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.5 0.92 0.4 0.08], ...
    'Callback', ...
    ['effect_gp(cur_effect).Visible = ''off'';',...
    'cur_effect = next_effect(total_effects, cur_effect);',...
    'effect_gp(cur_effect).Visible = ''on'';']);

prev_effect_but = uicontrol(effects_panel,...
    'String', '<',...
    'Style', 'pushbutton',...
    'Units', 'normalized',...
    'Position', [0.02 0.92 0.4 0.08], ...
    'Callback', ...
    ['effect_gp(cur_effect).Visible = ''off'';',...
    'cur_effect = prev_effect(total_effects, cur_effect);',...
    'effect_gp(cur_effect).Visible = ''on'';']);

%% ENVELOPE EFFECTS

env_config;

envelope_bar = uicontrol(effect_gp(1),...
    'String', env_names,...
    'Style', 'popupmenu',...
    'Units', 'normalized',...
    'Position', [0.05 0.60 0.9 0.2],...
    'Callback', ...
    'cur_note.env = env_funcs{envelope_bar.Value};');

%% FILTER EFFECTS

filter_config;
filter_var = 50;

filter_config = uicontrol(effect_gp(3),...
    'Style', 'edit',...
    'Units', 'normalized',...
    'Position', [0.05 0.75 0.9 0.1],...
    'String', '50',...
    'Callback',...
    ['filter_var = str2num(filter_config.String);'...
    'track_filter = @(s) filter_funcs{filter_bar.Value}(filter_var, s);']);

filter_bar = uicontrol(effect_gp(3),...
    'String', filter_names,...
    'Style', 'popupmenu',...
    'Units', 'normalized',...
    'Position', [0.05 0.50 0.9 0.2],...
    'Callback', ...
    'track_filter = @(s) filter_funcs{filter_bar.Value}(filter_var, s);');

%% VIBRATO EFFECTS

vib_amp_text = uicontrol(effect_gp(4),...
    'String', 'Vibrato Amplitude',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.05 0.80 0.9 0.1]);

vibrato_amp = uicontrol(effect_gp(4),...
    'Style', 'slider',...
    'Units', 'normalized',...
    'Position', [0.05 0.60 0.9 0.1], ...
    'Min', 0,...
    'Max', 8,...
    'Value', 0,...
    'Callback', ...
    'cur_note.vib_amp = vibrato_amp.Value;');

vib_freq_text = uicontrol(effect_gp(4),...
    'String', 'Vibrato Frequency',...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.05 0.4 0.9 0.1]);

vibrato_freq = uicontrol(effect_gp(4),...
    'Style', 'slider',...
    'Units', 'normalized',...
    'Position', [0.05 0.2 0.9 0.1], ...
    'Min', 0,...
    'Max', 16,...
    'Value', 5,...
    'Callback', ...
    'cur_note.vib_freq = vibrato_freq.Value;');


%% ADSR CONFIG PANEL

attack_pos = 0.2;
attack_amp = 1;

decay_pos = 0.3;
decay_amp = 0.5;

sustain_pos = 0.5;
sustain_amp = 0.5;

adsr_update = @(at, de, su) deal(...
    at,...
    at + (1 - at) * de,...
    at + (1 - at) * de + (1 - at - (1 - at) * de) * su);

[attack_pos, decay_pos, sustain_pos] = ...
    adsr_update(attack_pos, decay_pos, sustain_pos);

adsr_slider = @(val, call, pos) ... 
    uicontrol(effect_gp(2),...
    'Style', 'slider',...
    'Units', 'normalized',...
    'Position', pos, ...
    'Min', 0,...
    'Max', 1,...
    'Value', val,...
    'Callback', ...
    strcat(call, ...
    '[attack_pos, decay_pos, sustain_pos] = ', ...
    'adsr_update(atkpos.Value, decpos.Value, suspos.Value);', ...
    'cur_note.env = adsr_gen(', ...
    '[attack_pos attack_amp],',...
    '[decay_pos decay_amp],',...
    '[sustain_pos sustain_amp]);'));

adsr_label = @(text, pos) ...
    uicontrol(effect_gp(2),...
    'Style', 'text',...
    'String', text,...
    'Units', 'normalized',...
    'Position', pos);

atkpos = adsr_slider(attack_pos, ...
    'attack_pos = atkpos.Value;',...
    [0.15 0.8 0.8 0.1]);
atkpos_l = adsr_label('ATKPOS', [0 0.8 0.15 0.1]);

decpos = adsr_slider(decay_pos, ...
    'decay_pos = decpos.Value;',...
    [0.15 0.6 0.8 0.1]);
decpos_l = adsr_label('DECPOS', [0 0.6 0.15 0.1]);

suspos = adsr_slider(sustain_pos, ...
    'sustain_pos = suspos.Value;',...
    [0.15 0.4 0.8 0.1]);
suspos_l = adsr_label('SUSPOS', [0 0.4 0.15 0.1]);

atkamp = adsr_slider(attack_amp, ...
    'attack_amp = atkamp.Value;',...
    [0.15 0.7 0.8 0.1]);
atkamp_l = adsr_label('ATKAMP', [0 0.7 0.15 0.1]);

decamp = adsr_slider(decay_amp, ...
    'decay_amp = decamp.Value;',...
    [0.15 0.5 0.8 0.1]);
decamp_l = adsr_label('DECAMP', [0 0.5 0.15 0.1]);

susamp = adsr_slider(sustain_amp, ...
    'sustain_amp = susamp.Value;',...
    [0.15 0.3 0.8 0.1]);
susamp_l = adsr_label('SUSAMP', [0 0.3 0.15 0.1]);

%% FM MODULATION PANEL

fm_slider_gen = @(ind, pos) ... 
    uicontrol(effect_gp(5),...
    'Style', 'slider',...
    'Units', 'normalized',...
    'Position', [0.05 pos 0.9 0.1], ...
    'Min', 0,...
    'Max', 5,...
    'Value', 0,...
    'Callback', ...
    ['cur_note.timbre(',...
    num2str(ind),...
    ') = fm_slider(',...
    num2str(ind),...
    ').Value;']);

fm_slider_n = 8;
for ind = 1:fm_slider_n
    fm_slider(ind) = fm_slider_gen(ind, 1 - ind / fm_slider_n);
end

%% PRESETS PANEL (INSTRUMENTS)

presets_config;

presets_bar = uicontrol(effect_gp(6),...
    'String', presets_names,...
    'Style', 'popupmenu',...
    'Units', 'normalized',...
    'Position', [0.05 0.60 0.9 0.2],...
    'Callback', ...
    ['cur_note.timbre = presets_timbres{presets_bar.Value};',...
    'cur_note.env = presets_envs{presets_bar.Value};']);

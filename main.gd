extends Control

const BG := Color("#17151d")
const PANEL := Color("#211e29")
const PANEL_2 := Color("#282430")
const TEXT := Color("#f2eff7")
const MUTED := Color("#a9a1b4")
const ACCENT := Color("#a777ff")
const ACCENT_2 := Color("#c79cff")
const GREEN := Color("#41d39a")

var title_bar: HBoxContainer
var content: HBoxContainer
var preview: PanelContainer
var side: PanelContainer
var characters_overlay: PanelContainer
var status: Label
var selected_character := 0
var avatars := [
    {"name":"LEBEN", "state":"Neutral", "accent":"#8f66ff"},
    {"name":"LEBEN Feliz", "state":"Feliz", "accent":"#55c6ff"},
    {"name":"LEBEN Reacción", "state":"Sorprendido", "accent":"#ff9c61"},
]

func _ready() -> void:
    _build_ui()
    _show_preview()

func _font(node: Control, size: int, color: Color = TEXT) -> void:
    node.add_theme_font_size_override("font_size", size)
    node.add_theme_color_override("font_color", color)

func _panel_style(color: Color, radius: int = 10, border: Color = Color("#322c3a")) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = border
    s.set_border_width_all(1)
    s.corner_radius_top_left = radius
    s.corner_radius_top_right = radius
    s.corner_radius_bottom_left = radius
    s.corner_radius_bottom_right = radius
    s.content_margin_left = 14
    s.content_margin_right = 14
    s.content_margin_top = 12
    s.content_margin_bottom = 12
    return s

func _button(text: String, min_w: int = 40) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(min_w, 38)
    b.add_theme_stylebox_override("normal", _panel_style(PANEL_2, 8, Color("#342d3d")))
    b.add_theme_stylebox_override("hover", _panel_style(Color("#302936"), 8, ACCENT))
    b.add_theme_stylebox_override("pressed", _panel_style(Color("#3a3047"), 8, ACCENT_2))
    _font(b, 14)
    return b

func _build_ui() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_theme_constant_override("separation", 0)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 0)
    add_child(root)

    # Header
    title_bar = HBoxContainer.new()
    title_bar.custom_minimum_size.y = 58
    title_bar.add_theme_constant_override("separation", 8)
    var head_bg := PanelContainer.new()
    head_bg.custom_minimum_size.y = 58
    head_bg.add_theme_stylebox_override("panel", _panel_style(Color("#131117"), 0, Color("#2a2531")))
    root.add_child(head_bg)
    head_bg.add_child(title_bar)

    var logo := Label.new()
    logo.text = "L"
    logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    logo.custom_minimum_size = Vector2(40, 40)
    _font(logo, 24, ACCENT_2)
    title_bar.add_child(logo)

    var app := Label.new()
    app.text = "LEBEN Studio"
    _font(app, 16)
    app.custom_minimum_size.x = 122
    title_bar.add_child(app)

    var sep := VSeparator.new()
    sep.custom_minimum_size.x = 10
    title_bar.add_child(sep)

    for item in ["Archivo", "Editar", "Creador", "Ver", "Ventana", "Ayuda"]:
        var b := _button(item, 70)
        b.custom_minimum_size.y = 32
        b.pressed.connect(func(): status.text = item + " abierto")
        title_bar.add_child(b)

    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_bar.add_child(spacer)

    var info := _button("ⓘ", 38)
    info.tooltip_text = "Información del proyecto"
    info.pressed.connect(func(): status.text = "LEBEN Studio — prototipo")
    title_bar.add_child(info)

    var light := _button("☀", 38)
    light.tooltip_text = "Iluminación"
    light.pressed.connect(func(): status.text = "Iluminación: panel de configuración")
    title_bar.add_child(light)

    var people := _button("👥", 48)
    people.tooltip_text = "Personajes — abrir y cambiar personaje"
    people.add_theme_font_size_override("font_size", 22)
    people.pressed.connect(_open_characters)
    title_bar.add_child(people)

    var divider := VSeparator.new()
    divider.custom_minimum_size.x = 8
    title_bar.add_child(divider)

    for item in ["—", "□", "×"]:
        var win := _button(item, 38)
        win.pressed.connect(func(): status.text = "Control de ventana: " + item)
        title_bar.add_child(win)

    # Workspace navigation
    var nav_bg := PanelContainer.new()
    nav_bg.custom_minimum_size.y = 50
    nav_bg.add_theme_stylebox_override("panel", _panel_style(Color("#19161f"), 0, Color("#2a2531")))
    root.add_child(nav_bg)
    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation", 8)
    nav_bg.add_child(nav)
    for item in ["Creador", "Personajes", "Escenas", "Transmisión", "Audio", "Ajustes"]:
        var b := _button(item, 102)
        b.pressed.connect(func(): status.text = "Sección: " + item)
        nav.add_child(b)

    # Main area
    content = HBoxContainer.new()
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    content.add_theme_constant_override("margin_left", 12)
    content.add_theme_constant_override("margin_right", 12)
    root.add_child(content)

    side = PanelContainer.new()
    side.custom_minimum_size.x = 305
    side.add_theme_stylebox_override("panel", _panel_style(PANEL, 10))
    content.add_child(side)

    var side_box := VBoxContainer.new()
    side_box.add_theme_constant_override("separation", 8)
    side.add_child(side_box)

    var title := Label.new()
    title.text = "Personaje"
    _font(title, 18)
    side_box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Selector visual"
    _font(subtitle, 12, MUTED)
    side_box.add_child(subtitle)

    for t in ["Cambiar personaje", "Editar piezas", "Expresiones", "Posición / escala / rotación"]:
        var b := _button(t, 0)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(func(): status.text = t)
        side_box.add_child(b)

    var spacer2 := Control.new()
    spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
    side_box.add_child(spacer2)

    var hint := Label.new()
    hint.text = "La personalización se abrirá en paneles independientes."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _font(hint, 12, MUTED)
    side_box.add_child(hint)

    preview = PanelContainer.new()
    preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    preview.add_theme_stylebox_override("panel", _panel_style(Color("#0f0d13"), 10, Color("#342d3d")))
    content.add_child(preview)

    # Status bar
    var bottom := PanelContainer.new()
    bottom.custom_minimum_size.y = 38
    bottom.add_theme_stylebox_override("panel", _panel_style(Color("#131117"), 0, Color("#2a2531")))
    root.add_child(bottom)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 18)
    bottom.add_child(row)

    status = Label.new()
    status.text = "Transmisión: local"
    _font(status, 12, MUTED)
    row.add_child(status)

    var mic := Button.new()
    mic.text = "🎙 Micrófono"
    mic.tooltip_text = "Seleccionar micrófono"
    mic.pressed.connect(func(): status.text = "Micrófono: selector")
    row.add_child(mic)

    var out := Button.new()
    out.text = "🔊 Salida"
    out.tooltip_text = "Seleccionar parlante/auriculares"
    out.pressed.connect(func(): status.text = "Salida: selector")
    row.add_child(out)

    var grow := Control.new()
    grow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(grow)

    var version := Label.new()
    version.text = "v0.1.0 · LEBEN Studio"
    _font(version, 12, MUTED)
    row.add_child(version)

func _show_preview() -> void:
    for child in preview.get_children():
        child.queue_free()

    var holder := VBoxContainer.new()
    holder.alignment = BoxContainer.ALIGNMENT_CENTER
    holder.add_theme_constant_override("separation", 14)
    preview.add_child(holder)

    var caption := Label.new()
    caption.text = "Vista previa"
    caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _font(caption, 14, MUTED)
    holder.add_child(caption)

    var avatar := PanelContainer.new()
    avatar.custom_minimum_size = Vector2(380, 410)
    avatar.add_theme_stylebox_override("panel", _panel_style(Color(0.12,0.10,0.15,0.98), 18, Color("#3a3048")))
    holder.add_child(avatar)

    var av_box := VBoxContainer.new()
    av_box.alignment = BoxContainer.ALIGNMENT_CENTER
    av_box.add_theme_constant_override("separation", 8)
    avatar.add_child(av_box)

    var face := Label.new()
    face.text = "◕‿◕"
    face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _font(face, 66, Color("#f2d0c0"))
    av_box.add_child(face)

    var name := Label.new()
    name.text = avatars[selected_character]["name"]
    name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _font(name, 18)
    av_box.add_child(name)

    var state := Label.new()
    state.text = avatars[selected_character]["state"]
    state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _font(state, 12, MUTED)
    av_box.add_child(state)

    var actions := HBoxContainer.new()
    actions.alignment = BoxContainer.ALIGNMENT_CENTER
    actions.add_theme_constant_override("separation", 8)
    holder.add_child(actions)
    for key in ["F1", "F2", "F3", "F4"]:
        var b := _button(key, 54)
        b.pressed.connect(func(): status.text = "Reacción " + key)
        actions.add_child(b)

func _open_characters() -> void:
    if is_instance_valid(characters_overlay):
        characters_overlay.queue_free()
    characters_overlay = PanelContainer.new()
    characters_overlay.position = Vector2(380, 150)
    characters_overlay.size = Vector2(820, 500)
    characters_overlay.add_theme_stylebox_override("panel", _panel_style(Color("#1b1821"), 16, Color("#4a3c5c")))
    add_child(characters_overlay)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    characters_overlay.add_child(box)

    var header := HBoxContainer.new()
    box.add_child(header)
    var t := Label.new()
    t.text = "Personajes"
    t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _font(t, 20)
    header.add_child(t)
    var close := _button("×", 38)
    close.pressed.connect(func(): characters_overlay.queue_free())
    header.add_child(close)

    var hint := Label.new()
    hint.text = "Selecciona, previsualiza o crea un personaje nuevo."
    _font(hint, 12, MUTED)
    box.add_child(hint)

    var grid := GridContainer.new()
    grid.columns = 3
    grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    box.add_child(grid)

    for i in range(3):
        var card := PanelContainer.new()
        card.custom_minimum_size = Vector2(235, 305)
        card.add_theme_stylebox_override("panel", _panel_style(PANEL_2, 12, ACCENT if i == selected_character else Color("#3a3344")))
        grid.add_child(card)
        var cardbox := VBoxContainer.new()
        cardbox.alignment = BoxContainer.ALIGNMENT_CENTER
        cardbox.add_theme_constant_override("separation", 8)
        card.add_child(cardbox)

        var preview_avatar := Label.new()
        preview_avatar.text = "◕‿◕"
        preview_avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _font(preview_avatar, 50, Color("#f2d0c0"))
        cardbox.add_child(preview_avatar)

        var nm := Label.new()
        nm.text = avatars[i]["name"]
        nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _font(nm, 16)
        cardbox.add_child(nm)

        var st := Label.new()
        st.text = avatars[i]["state"]
        st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _font(st, 12, MUTED)
        cardbox.add_child(st)

        var choose := _button("Seleccionar", 130)
        choose.pressed.connect(func():
            selected_character = i
            characters_overlay.queue_free()
            _show_preview()
            status.text = "Personaje seleccionado: " + avatars[i]["name"]
        )
        cardbox.add_child(choose)

    var add := _button("+ Añadir personaje", 180)
    add.pressed.connect(func(): status.text = "Importar / crear personaje")
    box.add_child(add)

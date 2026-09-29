///|
/// MoonBit Pokedex - Full Featured App
/// - Navigation (List -> Detail)
/// - Favorites
/// - Swipe to Delete

///|
using @react_native {
  type Style,
  type StyleProp,
  type AlignItems,
  type JustifyContent,
  type FontWeight,
  type FlexDirection,
  type ListRenderItemInfo,
  type AlignSelf,
  type TextAlign,
  type FlexWrap,
  type GestureResponderEvent,
  type ImageSource,
  view,
  text,
  style,
  flat_list,
  activity_indicator,
  touchable_opacity,
  image,
  scroll_view,
}

///|
using @react {
  useState,
  useEffect,
  useCallback,
}

// ============================================================================
// FFI Definitions
// ============================================================================

///|
extern "js" fn ffi_fetch_pokemon_list_ffi(
  callback : (FixedArray[@core.Any]) -> Unit,
) -> Unit =
  #| (callback) => {
  #|   fetch('https://pokeapi.co/api/v2/pokemon?limit=151')
  #|     .then(res => res.json())
  #|     .then(data => callback(data.results))
  #|     .catch(err => { console.error(err); callback([]); });
  #| }

fn ffi_fetch_pokemon_list(
  callback : (Array[@core.Any]) -> Unit,
) -> Unit {
  ffi_fetch_pokemon_list_ffi(fn(__a1) { callback(Array::from_fixed_array(__a1)) })
}

///|
extern "js" fn ffi_fetch_pokemon_detail(
  id : Int,
  callback : (@core.Any) -> Unit,
) -> Unit =
  #| (id, callback) => {
  #|   fetch(`https://pokeapi.co/api/v2/pokemon/${id}`)
  #|     .then(res => res.json())
  #|     .then(data => callback(data))
  #|     .catch(err => { console.error(err); callback(null); });
  #| }

///|
extern "js" fn ffi_alert(title : String, message : String) -> Unit =
  #| (title, message) => {
  #|   const { Alert } = require('react-native');
  #|   Alert.alert(title, message);
  #| }

///|
extern "js" fn ffi_confirm_delete(
  name : String,
  on_confirm : () -> Unit,
) -> Unit =
  #| (name, onConfirm) => {
  #|   const { Alert } = require('react-native');
  #|   Alert.alert(
  #|     'Delete Pokemon',
  #|     `Remove ${name} from list?`,
  #|     [
  #|       { text: 'Cancel', style: 'cancel' },
  #|       { text: 'Delete', style: 'destructive', onPress: () => onConfirm() }
  #|     ]
  #|   );
  #| }

///|
extern "js" fn ffi_swipeable(
  render_right_actions : () -> @core.Any,
  children : @core.Any,
) -> @core.Any =
  #| (renderRightActions, children) => {
  #|   const React = require('react');
  #|   const { GestureHandlerRootView, Swipeable } = require('react-native-gesture-handler');
  #|   return React.createElement(Swipeable, {
  #|     renderRightActions: renderRightActions,
  #|     overshootRight: false,
  #|   }, children);
  #| }

///|
extern "js" fn ffi_gesture_root(children : @core.Any) -> @core.Any =
  #| (children) => {
  #|   const React = require('react');
  #|   const { GestureHandlerRootView } = require('react-native-gesture-handler');
  #|   return React.createElement(GestureHandlerRootView, { style: { flex: 1 } }, children);
  #| }

///|
extern "js" fn ffi_image_source(uri : String) -> @react_native.ImageSource =
  #| (uri) => ({ uri })

// ============================================================================
// Types
// ============================================================================

///|
priv struct Pokemon {
  id : Int
  name : String
  url : String
}

///|
fn Pokemon::from_any(any : @core.Any, index : Int) -> Pokemon {
  { id: index + 1, name: any["name"].cast(), url: any["url"].cast() }
}

///|
priv struct PokemonDetail {
  id : Int
  name : String
  height : Int
  weight : Int
  sprite : String
  types : Array[String]
  stats : Array[(String, Int)]
}

///|
fn PokemonDetail::from_any(any : @core.Any) -> PokemonDetail? {
  if @core.is_nullish(any) {
    return None
  }
  let types : Array[String] = []
  let types_arr : Array[@core.Any] = any["types"].cast()
  for i = 0; i < types_arr.length(); i = i + 1 {
    let t : String = types_arr[i]["type"]["name"].cast()
    types.push(t)
  }
  let stats : Array[(String, Int)] = []
  let stats_arr : Array[@core.Any] = any["stats"].cast()
  for i = 0; i < stats_arr.length(); i = i + 1 {
    let name : String = stats_arr[i]["stat"]["name"].cast()
    let value : Int = stats_arr[i]["base_stat"].cast()
    stats.push((name, value))
  }
  Some({
    id: any["id"].cast(),
    name: any["name"].cast(),
    height: any["height"].cast(),
    weight: any["weight"].cast(),
    sprite: any["sprites"]["front_default"].cast(),
    types,
    stats,
  })
}

///|
priv enum Screen {
  List
  Detail(Int)
}

// ============================================================================
// Styles
// ============================================================================

///|
let container_style : Style = style(
  flex=1,
  background_color="#f5f5f5",
)

///|
let header_style : Style = style(
  padding_top=60.0,
  padding_horizontal=20.0,
  padding_bottom=16.0,
  background_color="#ffffff",
  flex_direction=FlexDirection::Row,
  align_items=AlignItems::Center,
  justify_content=JustifyContent::SpaceBetween,
  border_bottom_width=1.0,
  border_bottom_color="#e0e0e0",
)

///|
let back_button_style : Style = style(
  padding=8.0,
)

///|
let back_text_style : Style = style(
  color="#007AFF",
  font_size=16.0,
)

///|
let title_style : Style = style(
  font_size=24.0,
  font_weight=FontWeight::Bold,
  color="#333333",
)

///|
let subtitle_style : Style = style(
  font_size=14.0,
  color="#666666",
  margin_top=4.0,
)

///|
let list_content_style : Style = style(
  padding_horizontal=16.0,
  padding_top=12.0,
  padding_bottom=100.0,
)

///|
let item_container_style : Style = style(
  margin_bottom=12.0,
)

///|
let item_style : Style = style(
  background_color="#ffffff",
  padding=16.0,
  border_radius=12.0,
  flex_direction=FlexDirection::Row,
  align_items=AlignItems::Center,
  shadow_color="#000000",
  shadow_opacity=0.1,
  shadow_radius=4.0,
  elevation=2,
)

///|
let item_image_style : Style = style(
  width=50.0,
  height=50.0,
  margin_right=12.0,
)

///|
let item_number_style : Style = style(
  font_size=14.0,
  color="#007AFF",
  font_weight=FontWeight::Bold,
  width=45.0,
)

///|
let item_name_style : Style = style(
  font_size=18.0,
  color="#333333",
  font_weight=FontWeight::W500,
  flex=1,
)

///|
let fav_button_style : Style = style(
  padding=8.0,
)

///|
let fav_text_style : Style = style(
  font_size=24.0,
)

///|
let delete_action_container_style : Style = style(
  flex=1,
  justify_content=JustifyContent::Center,
  align_items=AlignItems::Center,
  padding_left=12.0,
)

///|
let delete_action_style : Style = style(
  background_color="#FF3B30",
  justify_content=JustifyContent::Center,
  align_items=AlignItems::Center,
  width=80.0,
  padding_top=16.0,
  padding_bottom=16.0,
  border_radius=12.0,
)

///|
let delete_text_style : Style = style(
  color="#fff",
  font_weight=FontWeight::Bold,
)

///|
let loading_style : Style = style(
  flex=1,
  justify_content=JustifyContent::Center,
  align_items=AlignItems::Center,
)

///|
let loading_text_style : Style = style(
  color="#666666",
  margin_top=12.0,
  font_size=16.0,
)

// Detail styles
///|
let detail_container_style : Style = style(
  flex=1,
  padding=20.0,
)

///|
let detail_image_style : Style = style(
  width=200.0,
  height=200.0,
  align_self=AlignSelf::Center,
)

///|
let detail_name_style : Style = style(
  font_size=32.0,
  font_weight=FontWeight::Bold,
  color="#333333",
  text_align=TextAlign::Center,
  margin_top=16.0,
)

///|
let detail_id_style : Style = style(
  font_size=18.0,
  color="#007AFF",
  text_align=TextAlign::Center,
  margin_bottom=24.0,
)

///|
let detail_section_style : Style = style(
  background_color="#ffffff",
  padding=16.0,
  border_radius=12.0,
  margin_bottom=16.0,
  shadow_color="#000000",
  shadow_opacity=0.1,
  shadow_radius=4.0,
  elevation=2,
)

///|
let detail_label_style : Style = style(
  font_size=14.0,
  color="#666666",
  margin_bottom=8.0,
)

///|
let detail_value_style : Style = style(
  font_size=18.0,
  color="#333333",
  font_weight=FontWeight::W500,
)

///|
let type_container_style : Style = style(
  flex_direction=FlexDirection::Row,
  flex_wrap=FlexWrap::Wrap,
)

///|
let type_badge_style : Style = style(
  background_color="#007AFF",
  padding_horizontal=12.0,
  padding_vertical=6.0,
  border_radius=16.0,
  margin_right=8.0,
  margin_bottom=8.0,
)

///|
let type_text_style : Style = style(
  color="#fff",
  font_weight=FontWeight::Bold,
)

///|
let stat_row_style : Style = style(
  flex_direction=FlexDirection::Row,
  justify_content=JustifyContent::SpaceBetween,
  margin_bottom=8.0,
)

///|
let stat_name_style : Style = style(
  color="#666666",
  font_size=14.0,
)

///|
let stat_value_style : Style = style(
  color="#333333",
  font_weight=FontWeight::Bold,
)

// ============================================================================
// Helper Functions
// ============================================================================

///|
fn get_sprite_url(id : Int) -> String {
  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + id.to_string() + ".png"
}

///|
fn capitalize(s : String) -> String {
  if s.length() == 0 {
    return s
  }
  let chars = s.to_array()
  let first = chars[0].to_string().to_upper()
  let mut rest = ""
  for i = 1; i < chars.length(); i = i + 1 {
    rest = rest + chars[i].to_string()
  }
  first + rest
}

///|
fn is_favorite(favorites : Array[Int], id : Int) -> Bool {
  for i = 0; i < favorites.length(); i = i + 1 {
    if favorites[i] == id {
      return true
    }
  }
  false
}

///|
fn toggle_favorite(favorites : Array[Int], id : Int) -> Array[Int] {
  let new_favs : Array[Int] = []
  let mut found = false
  for i = 0; i < favorites.length(); i = i + 1 {
    if favorites[i] == id {
      found = true
    } else {
      new_favs.push(favorites[i])
    }
  }
  if not(found) {
    new_favs.push(id)
  }
  new_favs
}

///|
fn remove_pokemon(list : Array[Pokemon], id : Int) -> Array[Pokemon] {
  let new_list : Array[Pokemon] = []
  for i = 0; i < list.length(); i = i + 1 {
    if list[i].id != id {
      new_list.push(list[i])
    }
  }
  new_list
}

// ============================================================================
// Components
// ============================================================================

///|
fn render_delete_action(pokemon : Pokemon, on_delete : (Int) -> Unit) -> @react.Element {
  view(
    style=Some(StyleProp::from_style(delete_action_container_style)),
    children=[
      touchable_opacity(
        style=Some(StyleProp::from_style(delete_action_style)),
        on_press=Some(fn(_e : GestureResponderEvent) {
          ffi_confirm_delete(capitalize(pokemon.name), fn() { on_delete(pokemon.id) })
        }),
        children=[
          text(style=Some(StyleProp::from_style(delete_text_style)), children=[
            "Delete",
          ]),
        ],
      ),
    ],
  )
}

///|
fn render_pokemon_item(
  pokemon : Pokemon,
  favorites : Array[Int],
  on_press : (Int) -> Unit,
  on_toggle_fav : (Int) -> Unit,
  on_delete : (Int) -> Unit,
) -> @react.Element {
  let is_fav = is_favorite(favorites, pokemon.id)
  let sprite_url = get_sprite_url(pokemon.id)
  let inner = touchable_opacity(
    style=Some(StyleProp::from_style(item_style)),
    on_press=Some(fn(_e : GestureResponderEvent) { on_press(pokemon.id) }),
    children=[
      image(
        style=Some(StyleProp::from_style(item_image_style)),
        source=ImageSource::uri(sprite_url),
      ),
      text(
        style=Some(StyleProp::from_style(item_number_style)),
        children=["#" + pokemon.id.to_string()],
      ),
      text(
        style=Some(StyleProp::from_style(item_name_style)),
        children=[capitalize(pokemon.name)],
      ),
      touchable_opacity(
        style=Some(StyleProp::from_style(fav_button_style)),
        on_press=Some(fn(_e : GestureResponderEvent) { on_toggle_fav(pokemon.id) }),
        children=[
          text(
            style=Some(StyleProp::from_style(fav_text_style)),
            children=[if is_fav { "❤️" } else { "🤍" }],
          ),
        ],
      ),
    ],
  )
  // Wrap with swipeable
  let swipeable_el : @react.Element = ffi_swipeable(
    fn() { render_delete_action(pokemon, on_delete).as_any() },
    inner.as_any(),
  ).cast()
  view(style=Some(StyleProp::from_style(item_container_style)), children=[
    swipeable_el,
  ])
}

///|
fn render_list_screen(
  pokemon_list : Array[Pokemon],
  favorites : Array[Int],
  on_select : (Int) -> Unit,
  on_toggle_fav : (Int) -> Unit,
  on_delete : (Int) -> Unit,
) -> @react.Element {
  let fav_count = favorites.length()
  view(style=Some(StyleProp::from_style(container_style)), children=[
    // Header
    view(style=Some(StyleProp::from_style(header_style)), children=[
      view(children=[
        text(style=Some(StyleProp::from_style(title_style)), children=[
          "MoonBit Pokedex",
        ]),
        text(style=Some(StyleProp::from_style(subtitle_style)), children=[
          pokemon_list.length().to_string() +
          " Pokemon | " +
          fav_count.to_string() +
          " Favorites",
        ]),
      ]),
    ]),
    // List
    flat_list(
      data=pokemon_list,
      render_item=fn(info : ListRenderItemInfo[Pokemon]) {
        render_pokemon_item(
          info.item,
          favorites,
          on_select,
          on_toggle_fav,
          on_delete,
        )
      },
      key_extractor=Some(fn(p : Pokemon, _i : Int) { p.id.to_string() }),
      content_container_style=Some(StyleProp::from_style(list_content_style)),
    ),
  ])
}

///|
fn render_detail_screen(
  detail : PokemonDetail?,
  loading : Bool,
  is_fav : Bool,
  on_back : () -> Unit,
  on_toggle_fav : () -> Unit,
) -> @react.Element {
  view(style=Some(StyleProp::from_style(container_style)), children=[
    // Header with back button
    view(style=Some(StyleProp::from_style(header_style)), children=[
      touchable_opacity(
        style=Some(StyleProp::from_style(back_button_style)),
        on_press=Some(fn(_e : GestureResponderEvent) { on_back() }),
        children=[
          text(style=Some(StyleProp::from_style(back_text_style)), children=[
            "← Back",
          ]),
        ],
      ),
      touchable_opacity(
        style=Some(StyleProp::from_style(fav_button_style)),
        on_press=Some(fn(_e : GestureResponderEvent) { on_toggle_fav() }),
        children=[
          text(
            style=Some(StyleProp::from_style(fav_text_style)),
            children=[if is_fav { "❤️" } else { "🤍" }],
          ),
        ],
      ),
    ]),
    // Content
    if loading {
      view(style=Some(StyleProp::from_style(loading_style)), children=[
        activity_indicator(size=Some("large"), color=Some("#007AFF")),
        text(
          style=Some(StyleProp::from_style(loading_text_style)),
          children=["Loading details..."],
        ),
      ])
    } else {
      match detail {
        Some(d) => render_detail_content(d)
        None =>
          view(style=Some(StyleProp::from_style(loading_style)), children=[
            text(
              style=Some(StyleProp::from_style(loading_text_style)),
              children=["Failed to load"],
            ),
          ])
      }
    },
  ])
}

///|
fn render_detail_content(d : PokemonDetail) -> @react.Element {
  scroll_view(
    style=Some(StyleProp::from_style(detail_container_style)),
    children=[
      // Sprite
      image(
        style=Some(StyleProp::from_style(detail_image_style)),
        source=ImageSource::uri(d.sprite),
      ),
      // Name
      text(style=Some(StyleProp::from_style(detail_name_style)), children=[
        capitalize(d.name),
      ]),
      text(style=Some(StyleProp::from_style(detail_id_style)), children=[
        "#" + d.id.to_string().pad_start(3, '0'),
      ]),
      // Types
      view(style=Some(StyleProp::from_style(detail_section_style)), children=[
        text(style=Some(StyleProp::from_style(detail_label_style)), children=[
          "Types",
        ]),
        view(style=Some(StyleProp::from_style(type_container_style)), children={
          let type_badges : Array[&@react.ReactNode] = []
          for i = 0; i < d.types.length(); i = i + 1 {
            let badge : &@react.ReactNode = view(
              style=Some(StyleProp::from_style(type_badge_style)),
              children=[
                text(style=Some(StyleProp::from_style(type_text_style)), children=[
                  capitalize(d.types[i]),
                ]),
              ],
            )
            type_badges.push(badge)
          }
          type_badges
        }),
      ]),
      // Physical
      view(style=Some(StyleProp::from_style(detail_section_style)), children=[
        text(style=Some(StyleProp::from_style(detail_label_style)), children=[
          "Physical",
        ]),
        view(style=Some(StyleProp::from_style(stat_row_style)), children=[
          text(style=Some(StyleProp::from_style(stat_name_style)), children=[
            "Height",
          ]),
          text(style=Some(StyleProp::from_style(stat_value_style)), children=[
            (d.height.to_double() / 10.0).to_string() + " m",
          ]),
        ]),
        view(style=Some(StyleProp::from_style(stat_row_style)), children=[
          text(style=Some(StyleProp::from_style(stat_name_style)), children=[
            "Weight",
          ]),
          text(style=Some(StyleProp::from_style(stat_value_style)), children=[
            (d.weight.to_double() / 10.0).to_string() + " kg",
          ]),
        ]),
      ]),
      // Stats
      view(style=Some(StyleProp::from_style(detail_section_style)), children={
        let label : &@react.ReactNode = text(
          style=Some(StyleProp::from_style(detail_label_style)),
          children=["Base Stats"],
        )
        let stat_rows : Array[&@react.ReactNode] = [label]
        for i = 0; i < d.stats.length(); i = i + 1 {
          let (name, value) = d.stats[i]
          let row : &@react.ReactNode = view(
            style=Some(StyleProp::from_style(stat_row_style)),
            children=[
              text(style=Some(StyleProp::from_style(stat_name_style)), children=[
                capitalize(name),
              ]),
              text(style=Some(StyleProp::from_style(stat_value_style)), children=[
                value.to_string(),
              ]),
            ],
          )
          stat_rows.push(row)
        }
        stat_rows
      }),
    ],
  )
}

// ============================================================================
// App Component
// ============================================================================

///|
fn app_component() -> @react.Element {
  // State
  let (pokemon_list, set_pokemon_list) = useState([])
  let (favorites, set_favorites) = useState([])
  let (screen, set_screen) = useState(Screen::List)
  let (detail, set_detail) = useState(None)
  let (loading, set_loading) = useState(true)
  let (detail_loading, set_detail_loading) = useState(false)

  // Load pokemon list on mount
  useEffect(
    fn() {
      ffi_fetch_pokemon_list(fn(results) {
        let pokemons : Array[Pokemon] = []
        for i = 0; i < results.length(); i = i + 1 {
          pokemons.push(Pokemon::from_any(results[i], i))
        }
        set_pokemon_list(pokemons)
        set_loading(false)
      })
      fn() {}
    },
    [],
  )

  // Handlers
  let on_select = useCallback(
    fn(id : Int) {
      set_screen(Screen::Detail(id))
      set_detail_loading(true)
      set_detail(None)
      ffi_fetch_pokemon_detail(id, fn(data) {
        set_detail(PokemonDetail::from_any(data))
        set_detail_loading(false)
      })
    },
    [],
  )

  let on_back = useCallback(fn() { set_screen(Screen::List) }, [])

  let on_toggle_fav = useCallback(
    fn(id : Int) { set_favorites(toggle_favorite(favorites, id)) },
    [@core.any(favorites)],
  )

  let on_delete = useCallback(
    fn(id : Int) { set_pokemon_list(remove_pokemon(pokemon_list, id)) },
    [@core.any(pokemon_list)],
  )

  // Loading screen
  if loading {
    let loading_view = view(
      style=Some(StyleProp::from_style(container_style)),
      children=[
        view(style=Some(StyleProp::from_style(loading_style)), children=[
          activity_indicator(size=Some("large"), color=Some("#007AFF")),
          text(
            style=Some(StyleProp::from_style(loading_text_style)),
            children=["Loading Pokemon..."],
          ),
        ]),
      ],
    )
    return ffi_gesture_root(loading_view.as_any()).cast()
  }

  // Render based on current screen
  let content = match screen {
    Screen::List =>
      render_list_screen(
        pokemon_list,
        favorites,
        on_select,
        on_toggle_fav,
        on_delete,
      )
    Screen::Detail(id) => {
      let is_fav = is_favorite(favorites, id)
      render_detail_screen(
        detail,
        detail_loading,
        is_fav,
        on_back,
        fn() { on_toggle_fav(id) },
      )
    }
  }

  // Wrap with GestureHandlerRootView
  ffi_gesture_root(content.as_any()).cast()
}

///|
pub fn app() -> @react.Element {
  app_component()
}

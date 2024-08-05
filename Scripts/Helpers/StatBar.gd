class_name StatBar
extends ProgressBar

@export_category("Default Settings")
@export var label_text: String
@export var label_min: int = 0
@export var label_max: int = 100

@export_category("Required Nodes")
@export var label_text_node: Label
@export var label_value_node: Label
@export var container_type: ContainerType

var current_stat_count = 0

enum ContainerType 
{
    Health,
    Armor
}

func _ready():
    min_value = label_min
    max_value = label_max
    current_stat_count = label_max
    value = label_max
    label_text_node.text = label_text
    label_value_node.text = "%s / %s" % [label_max, label_max]
    _connect_proper_signal()

func _update_current(change_amnt: int):
    current_stat_count += change_amnt
    if container_type == ContainerType.Health && current_stat_count <= 0:
        SignalManager.emit_signal("game_over")
    value = current_stat_count
    label_value_node.text = "%s / %s" % [value, label_max]

func _connect_proper_signal():
    if container_type == ContainerType.Health:
        SignalManager.connect("update_health", Callable(self, "_update_current"))
    elif container_type == ContainerType.Armor:
        SignalManager.connect("update_armor", Callable(self, "_update_current"))

func initilize_instance(m: int):
    max_value = m
    value = m
    label_value_node.text = " %s / %s" % [m, m]

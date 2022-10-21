from typing import Dict, Any
from kitty.typing import BossType, WindowType, EdgeLiteral, TabType, TypedDict


def on_resize(boss: BossType, window: WindowType, data: Dict[str, Any]):
    # Here data will contain old_geometry and new_geometry
    pass

import subprocess
import sys

subjects = [
    "Data Mining",
    "Redes",
    "Bases de Datos",
    "PASEC",
    "Mercados Internacionales"
]

def get_dbus_cmd():
    for cmd in ["qdbus-qt6", "qdbus"]:
        try:
            subprocess.run([cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return cmd
        except FileNotFoundError:
            continue
    return None

dbus_cmd = get_dbus_cmd()
if not dbus_cmd:
    print("Error: No se encontró qdbus o qdbus-qt6.")
    sys.exit(1)

def run_dbus(path, method, *args):
    cmd = [dbus_cmd, "org.kde.ActivityManager", path, method] + list(args)
    return subprocess.check_output(cmd).decode().strip()

# Obtener actividades existentes para no duplicar
existing_activities_raw = run_dbus("/ActivityManager/Activities", "ListActivitiesWithNames")
# El formato suele ser una lista de pares ID Name o similar dependiendo de la versión
# Para simplificar, buscaremos si el nombre ya está en el output

for name in subjects:
    if name in existing_activities_raw:
        print(f"La actividad '{name}' ya existe. Saltando...")
        continue
    
    try:
        activity_id = run_dbus("/ActivityManager/Activities", "AddActivity", name)
        # Estado 2 es 'Started'
        run_dbus("/ActivityManager/Activities", "SetActivityState", activity_id, "2")
        print(f"Actividad creada: {name} (ID: {activity_id})")
    except Exception as e:
        print(f"Error al crear {name}: {e}")


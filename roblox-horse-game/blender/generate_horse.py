"""Generate a stylized low-poly horse mesh procedurally and export it to GLB/FBX.

This script uses Blender's Python API (bpy) and is meant to run headless:

    blender --background --python generate_horse.py -- \
        --output ./output --name LowPolyHorse \
        --coat 0.55,0.32,0.18 --mane 0.16,0.09,0.05

It was written and reviewed without a running Blender instance available
(this environment has no Blender install), so proportions are approximate.
Open the exported .glb in Blender afterwards and nudge the constants below
if anything looks off, then re-run.

All measurements are in meters, ground = Z 0, forward = +X, up = +Z.
"""

import argparse
import math
import os
import sys

import bpy

# ---------------------------------------------------------------------------
# Tunable proportions - adjust these if the generated shape looks wrong.
# ---------------------------------------------------------------------------
LEG_HEIGHT = 0.72
LEG_WIDTH = 0.16
LEG_DEPTH = 0.16
LEG_X_OFFSET = 0.55  # front/back distance from center
LEG_Y_OFFSET = 0.20  # left/right distance from center

BODY_LENGTH = 1.5
BODY_WIDTH = 0.55
BODY_HEIGHT = 0.62

NECK_LENGTH = 0.8
NECK_THICKNESS = 0.30
NECK_ANGLE_DEG = 55  # tilt from vertical, toward +X (forward)

HEAD_LENGTH = 0.55
HEAD_THICKNESS = 0.28
HEAD_ANGLE_DEG = 20  # tilt from vertical, toward +X (more forward than neck)

MUZZLE_LENGTH = 0.32
MUZZLE_WIDTH = 0.16
MUZZLE_HEIGHT = 0.16

EAR_HEIGHT = 0.18
EAR_RADIUS = 0.08

TAIL_LENGTH = 0.65
TAIL_THICKNESS = 0.14
TAIL_ANGLE_DEG = 35  # tilt from vertical, toward -X (backward)

MANE_HEIGHT = 0.14
MANE_THICKNESS = 0.05


def parse_args():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1 :]
    else:
        argv = []

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default=os.path.join(os.path.dirname(__file__), "output"))
    parser.add_argument("--name", default="LowPolyHorse")
    parser.add_argument("--coat", default="0.55,0.32,0.18", help="R,G,B 0-1 for the body coat")
    parser.add_argument("--mane", default="0.16,0.09,0.05", help="R,G,B 0-1 for mane/tail")
    return parser.parse_args(argv)


def parse_color(text):
    r, g, b = (float(x) for x in text.split(","))
    return (r, g, b, 1.0)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for mesh in list(bpy.data.meshes):
        bpy.data.meshes.remove(mesh)


def make_material(name, color):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = 0.85
    return mat


def add_box(name, size, location, rotation=(0.0, 0.0, 0.0), material=None):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    obj.rotation_euler = rotation
    if material:
        obj.data.materials.append(material)
    return obj


def add_cone(name, radius, depth, location, rotation=(0.0, 0.0, 0.0), material=None):
    bpy.ops.mesh.primitive_cone_add(radius1=radius, radius2=0.0, depth=depth, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.rotation_euler = rotation
    if material:
        obj.data.materials.append(material)
    return obj


def tilt_direction(angle_deg, sign=1.0):
    """Unit direction of a box's local +Z axis after rotating `angle_deg` about Y."""
    theta = math.radians(angle_deg)
    return (sign * math.sin(theta), 0.0, math.cos(theta))


def build_horse(coat_color, mane_color):
    coat_mat = make_material("HorseCoat", coat_color)
    mane_mat = make_material("HorseMane", mane_color)

    parts = []

    # --- Legs (front-left, front-right, back-left, back-right) ---
    leg_z = LEG_HEIGHT / 2
    for x_sign, x_off in ((1, LEG_X_OFFSET), (-1, LEG_X_OFFSET)):
        for y_sign in (1, -1):
            parts.append(
                add_box(
                    "Leg",
                    (LEG_WIDTH, LEG_DEPTH, LEG_HEIGHT),
                    (x_sign * x_off, y_sign * LEG_Y_OFFSET, leg_z),
                    material=coat_mat,
                )
            )

    # --- Body ---
    body_z = LEG_HEIGHT + BODY_HEIGHT / 2
    parts.append(
        add_box("Body", (BODY_LENGTH, BODY_WIDTH, BODY_HEIGHT), (0.0, 0.0, body_z), material=coat_mat)
    )

    # --- Neck (tilted box running from front-top of body upward/forward) ---
    neck_attach = (BODY_LENGTH / 2, 0.0, body_z + BODY_HEIGHT / 2)
    neck_dir = tilt_direction(NECK_ANGLE_DEG)
    neck_half = NECK_LENGTH / 2
    neck_center = tuple(neck_attach[i] + neck_half * neck_dir[i] for i in range(3))
    parts.append(
        add_box(
            "Neck",
            (NECK_THICKNESS, NECK_THICKNESS, NECK_LENGTH),
            neck_center,
            rotation=(0.0, math.radians(NECK_ANGLE_DEG), 0.0),
            material=coat_mat,
        )
    )

    # Thin mane strip along the back edge of the neck.
    mane_offset = NECK_THICKNESS / 2 + MANE_THICKNESS / 2
    mane_center = (neck_center[0] - mane_offset * neck_dir[2], neck_center[1], neck_center[2] + mane_offset * neck_dir[0])
    parts.append(
        add_box(
            "Mane",
            (MANE_THICKNESS, NECK_THICKNESS * 0.8, NECK_LENGTH * 0.9),
            mane_center,
            rotation=(0.0, math.radians(NECK_ANGLE_DEG), 0.0),
            material=mane_mat,
        )
    )

    # --- Head (tilted box continuing from the top of the neck) ---
    neck_top = tuple(neck_center[i] + neck_half * neck_dir[i] for i in range(3))
    head_dir = tilt_direction(HEAD_ANGLE_DEG)
    head_half = HEAD_LENGTH / 2
    head_center = tuple(neck_top[i] + head_half * head_dir[i] for i in range(3))
    parts.append(
        add_box(
            "Head",
            (HEAD_THICKNESS, HEAD_THICKNESS, HEAD_LENGTH),
            head_center,
            rotation=(0.0, math.radians(HEAD_ANGLE_DEG), 0.0),
            material=coat_mat,
        )
    )

    # --- Muzzle (small box extending forward from the head tip) ---
    head_top = tuple(head_center[i] + head_half * head_dir[i] for i in range(3))
    muzzle_dir = tilt_direction(80)  # mostly forward, slightly up
    muzzle_half = MUZZLE_LENGTH / 2
    muzzle_center = tuple(head_top[i] + muzzle_half * muzzle_dir[i] for i in range(3))
    parts.append(
        add_box(
            "Muzzle",
            (MUZZLE_WIDTH, MUZZLE_WIDTH, MUZZLE_LENGTH),
            muzzle_center,
            rotation=(0.0, math.radians(80), 0.0),
            material=coat_mat,
        )
    )

    # --- Ears (two cones on top of the head) ---
    for y_sign in (1, -1):
        ear_base = (head_center[0] - 0.05, y_sign * HEAD_THICKNESS * 0.35, head_center[2] + HEAD_THICKNESS * 0.5)
        parts.append(
            add_cone(
                "Ear",
                EAR_RADIUS,
                EAR_HEIGHT,
                (ear_base[0], ear_base[1], ear_base[2] + EAR_HEIGHT / 2),
                rotation=(math.radians(y_sign * 15), math.radians(-10), 0.0),
                material=coat_mat,
            )
        )

    # --- Tail (tilted box hanging down/back from the rear of the body) ---
    tail_attach = (-BODY_LENGTH / 2, 0.0, body_z + BODY_HEIGHT * 0.2)
    tail_dir = tilt_direction(TAIL_ANGLE_DEG, sign=-1.0)
    tail_half = TAIL_LENGTH / 2
    tail_center = tuple(tail_attach[i] + tail_half * tail_dir[i] for i in range(3))
    parts.append(
        add_box(
            "Tail",
            (TAIL_THICKNESS, TAIL_THICKNESS, TAIL_LENGTH),
            tail_center,
            rotation=(0.0, math.radians(-TAIL_ANGLE_DEG), 0.0),
            material=mane_mat,
        )
    )

    # --- Join everything into a single mesh ---
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[4]  # the Body object
    bpy.ops.object.join()

    horse = bpy.context.active_object
    horse.name = "LowPolyHorse"

    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    bpy.ops.object.shade_flat()

    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.normals_make_consistent(inside=False)
    bpy.ops.object.mode_set(mode="OBJECT")

    # Origin at world (0,0,0): ground level, centered on the leg footprint.
    bpy.context.scene.cursor.location = (0.0, 0.0, 0.0)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")

    return horse


def export(horse, output_dir, name):
    os.makedirs(output_dir, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    horse.select_set(True)
    bpy.context.view_layer.objects.active = horse

    glb_path = os.path.join(output_dir, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=glb_path, use_selection=True, export_format="GLB")

    fbx_path = os.path.join(output_dir, name + ".fbx")
    bpy.ops.export_scene.fbx(filepath=fbx_path, use_selection=True)

    print(f"Exported: {glb_path}")
    print(f"Exported: {fbx_path}")


def main():
    args = parse_args()
    clear_scene()
    horse = build_horse(parse_color(args.coat), parse_color(args.mane))
    export(horse, args.output, args.name)


if __name__ == "__main__":
    main()

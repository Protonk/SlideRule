"""
Layer 1.5 — Intercept policies.

Named policy builders that produce a base intercept c0 together with
transition corrections delta. Policies are rational and small so the
exact Day evaluator remains easy to inspect.
"""


def default_c0(exponent_q, x_width=1):
    """Centered baseline intercept used throughout the experiments."""
    return QQ(x_width) * QQ(1 - QQ(exponent_q)) / 2


def centered_state(r, q):
    """Mean-zero residue coordinate in roughly [-1/2, 1/2]."""
    if q <= 1:
        return QQ(0)
    return QQ(2 * r - q + 1) / QQ(2 * q)


def bit_sign(bit):
    """Map bits 0/1 to signs -1/+1."""
    return QQ(2 * bit - 1)


def default_step(depth, scale=16):
    """Small rational amplitude used by the built-in policies."""
    return QQ(1) / QQ(max(1, scale * depth))


def zero_policy(q, depth, exponent_q, x_width=1):
    """Single shared intercept, no path-dependent correction."""
    return {
        "name": "zero",
        "description": "baseline shared intercept",
        "c0_rat": default_c0(exponent_q, x_width),
        "delta_rat": {(r, b): QQ(0) for r in range(q) for b in (0, 1)},
    }


def state_bit_policy(q, depth, exponent_q, step=None, x_width=1):
    """
    Layer-invariant correction that depends on current residue and bit.
    """
    if step is None:
        step = default_step(depth, scale=16)

    delta = {}
    for r in range(q):
        for b in (0, 1):
            delta[(r, b)] = QQ(step) * centered_state(r, q) * bit_sign(b)

    return {
        "name": "state_bit",
        "description": "layer-invariant residue x bit correction",
        "c0_rat": default_c0(exponent_q, x_width),
        "delta_rat": delta,
    }


def terminal_bias_policy(q, depth, exponent_q, step=None, x_width=1):
    """
    Last-layer correction keyed by terminal residue.
    """
    if step is None:
        step = default_step(depth, scale=6)

    delta = {}
    for t in range(depth):
        for r in range(q):
            for b in (0, 1):
                delta[(t, r, b)] = QQ(0)

    for r in range(q):
        for b in (0, 1):
            r2 = (2 * r + b) % q
            delta[(depth - 1, r, b)] = QQ(step) * centered_state(r2, q)

    return {
        "name": "terminal_bias",
        "description": "last-layer bias by terminal residue",
        "c0_rat": default_c0(exponent_q, x_width),
        "delta_rat": delta,
    }


def hand_tuned_policy(q, depth, exponent_q, x_width=1):
    """
    Example explicit rational table.

    This preset is intentionally small and asymmetric; it exists to make
    a concrete hand-authored policy available for q=3 experiments.
    """
    if q != 3:
        raise ValueError("hand_tuned policy currently only supports q=3")

    delta = {
        (0, 0): -QQ(1) / QQ(128),
        (0, 1):  QQ(1) / QQ(96),
        (1, 0):  QQ(1) / QQ(256),
        (1, 1): -QQ(1) / QQ(256),
        (2, 0): -QQ(1) / QQ(96),
        (2, 1):  QQ(1) / QQ(128),
    }

    return {
        "name": "hand_tuned",
        "description": "explicit q=3 rational transition table",
        "c0_rat": default_c0(exponent_q, x_width),
        "delta_rat": delta,
    }


def build_intercept_policy(name, q, depth, exponent_q, x_width=1, **kwargs):
    """Dispatch by policy name."""
    if name == "zero":
        return zero_policy(q, depth, exponent_q, x_width=x_width)
    if name == "state_bit":
        return state_bit_policy(q, depth, exponent_q, step=kwargs.get("step"),
                                x_width=x_width)
    if name == "terminal_bias":
        return terminal_bias_policy(q, depth, exponent_q, step=kwargs.get("step"),
                                    x_width=x_width)
    if name == "hand_tuned":
        return hand_tuned_policy(q, depth, exponent_q, x_width=x_width)
    raise ValueError(f"unknown intercept policy: {name}")

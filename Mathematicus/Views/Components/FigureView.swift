import SwiftUI

/// Jednoduché schematické obrázky geometrických útvarů a těles.
struct FigureView: View {
    let figure: Figure
    var color: Color = .blue

    var body: some View {
        Canvas { ctx, size in
            let s = Painter(ctx: ctx, size: size, color: color)
            switch figure {
            case .rectangle(let a, let b): s.rectangle(a: a, b: b, square: false)
            case .square(let a): s.rectangle(a: a, b: a, square: true)
            case .cuboid(let a, let b, let c): s.cuboid(a: a, b: b, c: c, cube: false)
            case .cube(let a): s.cuboid(a: a, b: "", c: "", cube: true)
            case .rightTriangle(let a, let b, let c, let alpha): s.rightTriangle(a: a, b: b, c: c, alpha: alpha)
            case .triangle(let a, let v): s.triangle(a: a, v: v)
            case .parallelogram(let a, let v): s.parallelogram(a: a, v: v)
            case .trapezoid(let a, let c, let v): s.trapezoid(a: a, c: c, v: v)
            case .circle(let r): s.circle(r: r)
            case .cylinder(let r, let v): s.cylinder(r: r, v: v)
            case .cone(let r, let v): s.cone(r: r, v: v)
            case .pyramid(let a, let v): s.pyramid(a: a, v: v)
            case .sphere(let r): s.sphere(r: r)
            case .prism(let a, let b, let h): s.prism(a: a, b: b, h: h)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct Painter {
    let ctx: GraphicsContext
    let size: CGSize
    let color: Color

    var w: CGFloat { size.width }
    var h: CGFloat { size.height }
    var cx: CGFloat { w / 2 }

    func stroke(_ p: Path, dashed: Bool = false) {
        ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round,
                                                               dash: dashed ? [5, 5] : []))
    }

    func fill(_ p: Path) { ctx.fill(p, with: .color(color.opacity(0.15))) }

    func label(_ s: String, _ p: CGPoint) {
        guard !s.isEmpty else { return }
        ctx.draw(Text(s).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.primary), at: p)
    }

    func poly(_ pts: [CGPoint]) -> Path {
        var p = Path()
        p.addLines(pts)
        p.closeSubpath()
        return p
    }

    func line(_ a: CGPoint, _ b: CGPoint) -> Path {
        var p = Path()
        p.move(to: a)
        p.addLine(to: b)
        return p
    }

    // MARK: Rovinné útvary

    func rectangle(a: String, b: String, square: Bool) {
        let rh = h * 0.62
        let rw = square ? rh : min(w * 0.5, rh * 1.7)
        let r = CGRect(x: cx - rw / 2, y: h * 0.12, width: rw, height: rh)
        let p = Path(r)
        fill(p); stroke(p)
        label(a, CGPoint(x: r.midX, y: r.maxY + 14))
        if !square { label(b, CGPoint(x: r.maxX + 8 + CGFloat(b.count) * 4, y: r.midY)) }
    }

    func rightTriangle(a: String, b: String, c: String, alpha: Bool) {
        let C = CGPoint(x: cx - w * 0.2, y: h * 0.85)
        let B = CGPoint(x: C.x, y: h * 0.1)
        let A = CGPoint(x: cx + w * 0.25, y: C.y)
        let p = poly([A, B, C])
        fill(p); stroke(p)
        let m: CGFloat = 14
        var sq = Path()
        sq.move(to: CGPoint(x: C.x, y: C.y - m))
        sq.addLine(to: CGPoint(x: C.x + m, y: C.y - m))
        sq.addLine(to: CGPoint(x: C.x + m, y: C.y))
        stroke(sq)
        label(a, CGPoint(x: C.x - 12 - CGFloat(a.count) * 4, y: (B.y + C.y) / 2))
        label(b, CGPoint(x: (A.x + C.x) / 2, y: C.y + 14))
        label(c, CGPoint(x: (A.x + B.x) / 2 + 16 + CGFloat(c.count) * 3, y: (A.y + B.y) / 2 - 6))
        if alpha {
            var arc = Path()
            let angle = atan2(B.y - A.y, B.x - A.x)
            arc.addArc(center: A, radius: 26, startAngle: .radians(.pi), endAngle: .radians(Double(angle)), clockwise: false)
            stroke(arc)
            label("α", CGPoint(x: A.x - 38, y: A.y - 10))
        }
    }

    func triangle(a: String, v: String) {
        let A = CGPoint(x: cx - w * 0.25, y: h * 0.85)
        let B = CGPoint(x: cx + w * 0.25, y: h * 0.85)
        let C = CGPoint(x: cx + w * 0.08, y: h * 0.1)
        let p = poly([A, B, C])
        fill(p); stroke(p)
        stroke(line(C, CGPoint(x: C.x, y: A.y)), dashed: true)
        label(a, CGPoint(x: cx, y: A.y + 14))
        label("v = " + v, CGPoint(x: C.x + 30, y: h * 0.5))
    }

    func parallelogram(a: String, v: String) {
        let off = w * 0.1
        let A = CGPoint(x: cx - w * 0.28, y: h * 0.85), B = CGPoint(x: cx + w * 0.18, y: h * 0.85)
        let C = CGPoint(x: B.x + off, y: h * 0.12), D = CGPoint(x: A.x + off, y: h * 0.12)
        let p = poly([A, B, C, D])
        fill(p); stroke(p)
        stroke(line(D, CGPoint(x: D.x, y: A.y)), dashed: true)
        label(a, CGPoint(x: (A.x + B.x) / 2, y: A.y + 14))
        label("v = " + v, CGPoint(x: D.x + 32, y: h * 0.5))
    }

    func trapezoid(a: String, c: String, v: String) {
        let A = CGPoint(x: cx - w * 0.28, y: h * 0.85), B = CGPoint(x: cx + w * 0.28, y: h * 0.85)
        let C = CGPoint(x: cx + w * 0.12, y: h * 0.15), D = CGPoint(x: cx - w * 0.1, y: h * 0.15)
        let p = poly([A, B, C, D])
        fill(p); stroke(p)
        stroke(line(D, CGPoint(x: D.x, y: A.y)), dashed: true)
        label(a, CGPoint(x: cx, y: A.y + 14))
        label(c, CGPoint(x: (C.x + D.x) / 2, y: C.y - 12))
        label("v = " + v, CGPoint(x: D.x - 34, y: h * 0.5))
    }

    func circle(r: String) {
        let rad = h * 0.4
        let center = CGPoint(x: cx, y: h * 0.5)
        let p = Path(ellipseIn: CGRect(x: center.x - rad, y: center.y - rad, width: 2 * rad, height: 2 * rad))
        fill(p); stroke(p)
        stroke(line(center, CGPoint(x: center.x + rad, y: center.y)))
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)), with: .color(color))
        label("r = " + r, CGPoint(x: center.x + rad / 2, y: center.y - 13))
    }

    // MARK: Tělesa

    func cuboid(a: String, b: String, c: String, cube: Bool) {
        let fw = cube ? h * 0.55 : min(w * 0.42, h * 0.95)
        let fh = h * 0.55
        let dx = cube ? h * 0.22 : h * 0.25, dy = cube ? h * 0.2 : h * 0.22
        let x0 = cx - (fw + dx) / 2, y0 = h * 0.1 + dy
        let f = CGRect(x: x0, y: y0, width: fw, height: fh)
        let back = f.offsetBy(dx: dx, dy: -dy)
        fill(Path(f))
        // skryté hrany
        stroke(line(CGPoint(x: back.minX, y: back.maxY), CGPoint(x: back.maxX, y: back.maxY)), dashed: true)
        stroke(line(CGPoint(x: back.minX, y: back.minY), CGPoint(x: back.minX, y: back.maxY)), dashed: true)
        stroke(line(CGPoint(x: f.minX, y: f.maxY), CGPoint(x: back.minX, y: back.maxY)), dashed: true)
        // viditelné hrany
        stroke(Path(f))
        stroke(poly([CGPoint(x: f.minX, y: f.minY), CGPoint(x: back.minX, y: back.minY),
                     CGPoint(x: back.maxX, y: back.minY), CGPoint(x: f.maxX, y: f.minY)]))
        stroke(poly([CGPoint(x: f.maxX, y: f.minY), CGPoint(x: back.maxX, y: back.minY),
                     CGPoint(x: back.maxX, y: back.maxY), CGPoint(x: f.maxX, y: f.maxY)]))
        label(a, CGPoint(x: f.midX, y: f.maxY + 14))
        if !cube {
            label(b, CGPoint(x: f.maxX + dx / 2 + 16, y: f.maxY - dy / 2 + 4))
            label(c, CGPoint(x: f.minX - 12 - CGFloat(c.count) * 3, y: f.midY))
        }
    }

    func prism(a: String, b: String, h hh: String) {
        let depth = w * 0.3
        let C = CGPoint(x: cx - w * 0.28, y: h * 0.85)
        let A = CGPoint(x: C.x, y: h * 0.35)
        let B = CGPoint(x: C.x + w * 0.22, y: C.y)
        let off = CGPoint(x: depth, y: -h * 0.15)
        func o(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x + off.x, y: p.y + off.y) }
        fill(poly([A, B, C]))
        stroke(poly([A, B, C]))
        stroke(poly([o(A), o(B), o(C)]))
        stroke(line(A, o(A))); stroke(line(B, o(B))); stroke(line(C, o(C)), dashed: true)
        label(a, CGPoint(x: C.x - 14, y: (A.y + C.y) / 2))
        label(b, CGPoint(x: (B.x + C.x) / 2, y: C.y + 14))
        label("h = " + hh, CGPoint(x: (B.x + o(B).x) / 2 + 26, y: (B.y + o(B).y) / 2 + 10))
    }

    func cylinder(r: String, v: String) {
        let rw = min(w * 0.22, h * 0.45), eh = rw * 0.35
        let top = h * 0.15, bottom = h * 0.85
        let topRect = CGRect(x: cx - rw, y: top - eh / 2, width: 2 * rw, height: eh)
        let botRect = CGRect(x: cx - rw, y: bottom - eh / 2, width: 2 * rw, height: eh)
        var body = Path()
        body.addRect(CGRect(x: cx - rw, y: top, width: 2 * rw, height: bottom - top))
        fill(body)
        stroke(Path(ellipseIn: topRect))
        stroke(Path(ellipseIn: botRect))
        stroke(line(CGPoint(x: cx - rw, y: top), CGPoint(x: cx - rw, y: bottom)))
        stroke(line(CGPoint(x: cx + rw, y: top), CGPoint(x: cx + rw, y: bottom)))
        stroke(line(CGPoint(x: cx, y: top), CGPoint(x: cx + rw, y: top)))
        label("r = " + r, CGPoint(x: cx + rw / 2, y: top - eh / 2 - 12))
        label("v = " + v, CGPoint(x: cx + rw + 34, y: (top + bottom) / 2))
    }

    func cone(r: String, v: String) {
        let rw = min(w * 0.24, h * 0.5), eh = rw * 0.35
        let apex = CGPoint(x: cx, y: h * 0.08), base = h * 0.82
        let tri = poly([apex, CGPoint(x: cx - rw, y: base), CGPoint(x: cx + rw, y: base)])
        fill(tri)
        stroke(line(apex, CGPoint(x: cx - rw, y: base)))
        stroke(line(apex, CGPoint(x: cx + rw, y: base)))
        stroke(Path(ellipseIn: CGRect(x: cx - rw, y: base - eh / 2, width: 2 * rw, height: eh)))
        if !v.isEmpty {
            stroke(line(apex, CGPoint(x: cx, y: base)), dashed: true)
            label("v = " + v, CGPoint(x: cx - 30, y: h * 0.48))
        }
        stroke(line(CGPoint(x: cx, y: base), CGPoint(x: cx + rw, y: base)))
        label("r = " + r, CGPoint(x: cx + rw / 2, y: base + eh / 2 + 12))
    }

    func pyramid(a: String, v: String) {
        let bw = min(w * 0.4, h * 0.9), dx = bw * 0.35, dy = h * 0.18
        let base = h * 0.88
        let A = CGPoint(x: cx - bw / 2 - dx / 2, y: base), B = CGPoint(x: cx + bw / 2 - dx / 2, y: base)
        let C = CGPoint(x: B.x + dx, y: base - dy), D = CGPoint(x: A.x + dx, y: base - dy)
        let center = CGPoint(x: (A.x + C.x) / 2, y: (A.y + C.y) / 2)
        let V = CGPoint(x: center.x, y: h * 0.06)
        fill(poly([A, B, C, V]))
        stroke(line(A, B)); stroke(line(B, C))
        stroke(line(C, D), dashed: true); stroke(line(D, A), dashed: true)
        stroke(line(A, V)); stroke(line(B, V)); stroke(line(C, V)); stroke(line(D, V), dashed: true)
        if !v.isEmpty {
            stroke(line(V, center), dashed: true)
            label("v = " + v, CGPoint(x: center.x - 32, y: (V.y + center.y) / 2 + 10))
        }
        label(a, CGPoint(x: (A.x + B.x) / 2, y: base + 13))
    }

    func sphere(r: String) {
        let rad = h * 0.42
        let c = CGPoint(x: cx, y: h * 0.5)
        let p = Path(ellipseIn: CGRect(x: c.x - rad, y: c.y - rad, width: 2 * rad, height: 2 * rad))
        fill(p); stroke(p)
        stroke(Path(ellipseIn: CGRect(x: c.x - rad, y: c.y - rad * 0.25, width: 2 * rad, height: rad * 0.5)), dashed: true)
        stroke(line(c, CGPoint(x: c.x + rad, y: c.y)))
        label("r = " + r, CGPoint(x: c.x + rad / 2, y: c.y - 14))
    }
}

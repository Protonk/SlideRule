% Day (2023) coarse-stage optimal magic constants.
%
% Compact "happy path" for the classic FRSR exponent x^(-1/2), distilled
% from "Generalising the Fast Reciprocal Square Root Algorithm"
% (arXiv:2307.15600). The structure here matches the six core ideas:
%   1. the pseudolog L and its inverse
%   2. the coarse approximation y = L^{-1}((c - L(x))/2)
%   3. the quality metric z(x) = x * y^2
%   4. the finite candidate extrema for z
%   5. the optimal choice of the magic constant c
%   6. the resulting coarse-stage error bound

% 1. Pseudolog and inverse.
% The IEEE-754 float bit-pattern of x approximately encodes log2(x).
% Day's pseudolog makes that precise:
%   L(x) = floor(log2 x) + x * 2^{-floor(log2 x)} - 1.
% It is piecewise linear on each octave [2^e, 2^(e+1)), agrees with log2
% at powers of two, and has an explicit inverse on each affine segment.
plog     = @(x) floor(log2(x)) + x .* 2.^(-floor(log2(x))) - 1;
plog_inv = @(X) 2.^floor(X) .* (1 + X - floor(X));

% 2. Coarse approximation: line X + 2Y = c in pseudolog space.
% For y ~ x^(-1/2), the relation log2(y) ~ -(1/2) log2(x) becomes the
% affine line Y = (c - X)/2 in pseudolog coordinates. The classic FRSR
% bit-hack is exactly this coarse stage, with the magic constant encoding c.
c = 0.5;  % we will justify this value later
coarse = @(x) plog_inv((c - plog(x)) ./ 2);

% 3. Quality metric z(x) = x * y^2.  z = 1 iff y = x^{-1/2} exactly.
% The deviation of z from 1 measures coarse-stage error. For b = 2, z is
% periodic as a function of X = L(x), so one full period is x in [1, 4).
x = linspace(1 + 1e-6, 4 - 1e-6, 100000);
y = coarse(x);
z = x .* y.^2;

printf('z range: [%.10f, %.10f]\n', min(z), max(z));

% Since z = x y^2 and y_exact^2 = 1/x, we have y / y_exact = sqrt(z).
% So the relative error of y lives in [sqrt(z_min) - 1, sqrt(z_max) - 1]:
% tighter z range => smaller worst-case error.  This is why the optimization
% target is rho = z_max / z_min, not any pointwise comparison of y to x^{-1/2}.
y_exact = x.^(-0.5);
ratio = y ./ y_exact;
printf('max |y/y_exact - sqrt(z)|: %.2e\n', max(abs(ratio - sqrt(z))));

% 4. z is periodic (period b=2 in X) and piecewise-smooth.
%    Extrema occur only at kinks: integer X, integer Y, integer X-Y.
%    This gives a finite candidate set per period.
% At each kink, z takes a zeta-family value
%   zeta(r, k) = 2^(s-r) * (1 + (r+t)/k)^k
% with s = floor(c), t = frac(c), and r the remainder class mod k of the
% relevant integer crossing.
% Note: this closure captures the current value of c.
zeta = @(r, k) 2.^(floor(c) - r) .* (1 + (r + c - floor(c)) ./ k).^k;

% For a = 1, b = 2, gamma = a + b = 3:
%   H: integer X crossings, k = b = 2
%   V: integer Y crossings, k = a = 1
%   D: integer X-Y crossings, k = gamma = 3
H = [zeta(0,2), zeta(1,2)];            % b = 2 candidates
V = [zeta(0,1)];                       % a = 1 candidate
D = [zeta(0,3), zeta(1,3), zeta(2,3)]; % gamma = 3 candidates
candidates = [H, V, D];

printf('\nH:  '); printf('%.6f  ', H); printf('\n');
printf('V:  '); printf('%.6f  ', V); printf('\n');
printf('D:  '); printf('%.6f  ', D); printf('\n');

z_min = min(candidates);
z_max = max(candidates);
rho = z_max / z_min;
printf('\nz_min = %.10f\nz_max = %.10f\nrho   = %.10f\n', z_min, z_max, rho);

% 5. Which candidates win, and how to choose c.
% rho depends only on t = frac(c), not on s = floor(c), so the optimization
% is over t in [0, 1). Day's analysis identifies the winning candidates via
% two switchover quantities:
%   t0(alpha) controls whether z_min comes from V or H
%   t1(gamma) controls which D candidate gives z_max
% For alpha = 1, the optimum is the clamp
%   t* = clamp(t1, (rbar-1)/beta, rbar/beta).
t0_alpha = 1/log(2) - 1;                          % t0(1)
phi_gamma = 2^(1/3) / (2^(1/3) - 1) - 3;          % phi(3)
rbar = floor(phi_gamma);
t1 = phi_gamma - rbar;
beta = 2;
t_star = min(max(t1, (rbar-1)/beta), rbar/beta);   % clamp

printf('\nt0(alpha=1) = %.6f\n', t0_alpha);
printf('phi(gamma=3) = %.6f,  rbar = %d,  t1 = %.6f\n', phi_gamma, rbar, t1);
printf('t* = clamp(%.4f, %.4f, %.4f) = %.4f\n', ...
       t1, (rbar-1)/beta, rbar/beta, t_star);
printf('c* = s + t* = 0 + 0.5 = 0.5\n');

% 6. Provable error bound.
% The best constant correction rescales y by
%   C = 2 / (sqrt(z_min) + sqrt(z_max))
% which equalizes the positive and negative relative error. The degree-0
% minimax bound is then
%   (rho^(1/2) - 1) / (rho^(1/2) + 1).
% In practice this scale factor is absorbed into the choice of s = floor(c).
rho_half = rho^(1/2);
rel_err = (rho_half - 1) / (rho_half + 1);
printf('\nrho = %g  =>  worst-case relative error = %.4f%%\n', rho, 100*rel_err);

% Cross-check: rescale y by the optimal constant k = 2/(sqrt(z_min)+sqrt(z_max)),
% then compare to y_exact. This empirical value should match the closed-form
% equioscillation bound above up to numerical sampling error.
k_opt = 2 / (sqrt(z_min) + sqrt(z_max));
empirical_err = max(abs(k_opt .* y ./ y_exact - 1));
printf('empirical max |rel error| (rescaled):      %.4f%%\n', 100*empirical_err);

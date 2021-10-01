import sys
from jinja2 import Template
t1 = Template("point_{{n}} <- llvm_fresh_var \"point_{{n}}\" POINTonE1_affine_type;")
t2 = Template("llvm_points_to_untyped (llvm_elem points_ptr {{n}}) (llvm_term point_{{n}});")
t3 = Template("llvm_precond {%raw%}{{{%endraw%} POINTonE1_affine_invariant point_{{n}} {%raw%}}}{%endraw%};")
N=int(sys.argv[1])
for n in range(N):
    print(t1.render(n=str(n)))
    print(t2.render(n=str(n)))
    print(t3.render(n=str(n)))

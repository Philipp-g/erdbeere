[![Code Climate](https://codeclimate.com/github/oqpvc/erdbeere/badges/gpa.svg)](https://codeclimate.com/github/oqpvc/erdbeere)
[![Build Status](https://travis-ci.org/oqpvc/erdbeere.svg?branch=master)](https://travis-ci.org/oqpvc/erdbeere)

# erdbeere

ErDBeere is short for “Erkenntnisfördernde Datenbank zur
Beispielerfassung und -entwicklung” (informative database for
developing and managing examples) and should be thought of as an
e-learning tool for higher (i. e., University-level) mathematics.

It aims to store mathematical examples somewhat like the
[ring database](http://ringtheory.herokuapp.com) and is supposed to
help students explore features of mathematical objects. Consider the
following questions:

- What does a principal ideal domain that is not Euclidean look like?
- What does a quasi-projective and proper morphism between schemes
  look like, that isn't projective?
- Is there a ring that is a principal ideal domain, but not a unique
  factorization domain?
  
The first question has a simple enough answer with the ring of
integers of __Q__(√-19). The second also has an example as the answer,
but it is worthwhile to know that every quasi-projective proper
morphism X→Y is projective if Y is qcqs. The third question of course
has no example at all, as every principal ideal domain is a UFD.

ErDBeere wants to represent all the data in the answers above, i.e.,
*concrete examples* and *abstract implications*, in the nicest
possible manner.

## Data Structures

The “nicest possible manner” is of course a Web 2.0 application. This
is hence a *Ruby on Rails* application, which isn't all that suitable
to represent the aforementioned data — especially the mathematical
implications.

We will explain the internal data structures using example pieces of
code.

### Categories, Properties and Implications

```ruby
ring = Structure.create({name: 'Ring'})
ring.definition = 'A ring $R$ is an abelian group together with a ' +
                  'map $R\times R …'

unitary = Property.create({name: 'unitary', structure: ring})
unitary.definition = '…'
…
l_noeth = Property.create({name: 'left Noetherian', structure: ring})
r_noeth = Property.create({name: 'right Noetherian', structure: ring})
comm = Property.create({name: 'commutative', structure: ring})
vnr = Property.create({name: 'von Neumann regular (aka absolutely flat)',
                        structure: ring})

```

Rings are easy classes of objects to represent, as they don't depend
on other structures. But as soon as $R$-modules enter the picture,
this becomes decidedly more complicated, as their properties may
depend on their ground ring. Structures can hence have building
blocks.

```ruby
rmod = Structure.create({name: '$R$-(left-)Module'})
base_ring = BuildingBlock.create({name: 'base ring',
                                   explained_structure: rmod,
                                   structure: ring, definition: 'A ' +
                                   'ring homomorphism $R\longrightarrow ' +
                                   '\mathrm{End}(M)$ …'})
```

Now we want to encode the following result:
“A finitely generated $R$-left-module over a left Noetherian ring
is itself Noetherian”.

```ruby
fin_gen = Property.create({name: 'finitely generated', structure: rmod})
noeth_module = Property.create({name: 'ascending chain condition for ' +
                               'submodules', structure: rmod})

base_ring_is_lnoeth = Atom.create({stuff_w_props: base_ring, property:
                                   l_noeth})
module_is_fg = Atom.create({stuff_w_props: rmod, property: fin_gen})
module_has_acc = Atom.create({stuff_w_props: rmod, property: noeth_module})

fg_and_noeth_base_ring_implies_noeth =Implication.create({atoms:
                                                           [module_is_fg, base_ring_is_lnoeth],
                                                           implies:
                                                           module_has_acc})
```

### Examples

An example for a structure in the sense above depends on examples of
all of its building blocks (e. g., for an $R$-module we first need a
ring $R$). Consider the following code snippet:

```ruby
integers = Example.create({structure: ring})
ExampleTruth.create({example: integers, property: comm, satisfied: true})
ExampleTruth.create({example: integers, property: l_noeth, satisfied: true})
ExampleTruth.create({example: integers, property: vnr, satisfied: false})

zee_r = Example.create({structure: rmod})
BuildingBlockRealization.create({example: zee_r, building_block:
  base_ring, realization: integers})
ExampleTruth.create({example: zee_r, property: fin_gen, satisfied: true})
```

### Using the logic engine

The internal logic engine is as stupid as one get away with. I assume that it is
hence very slow, which still might be fast enough for practical purposes.
Working with it roughly looks like this:

```ruby
zee_r.satisfies?(module_has_acc)
zee_r.satisfies?(Atom.find_or_create_by({stuff_w_props:
                                                   building_blocks(:base_ring),
                                                   property:
                                                   properties(:r_noeth)}))
zee_r.all_that_is_true.each do |a|
  puts a.to_s
end
```

As one can see, the implications on the level of examples work recursively: Even
though we never had an ExampleTruth that stated that for commutative *base
rings* (and not *rings*) left and right Noetherian are equivalent, the logic
engine derives those kind of statements from the bottom up.

In contrast to that, we cannot encode implications from the top down (such as:
the existence of a separated morphism X→ Y with Y separated as a scheme implies
that X is itself separated, where we view X and Y as the building blocks
*domain* and *codomain* of the structure *scheme morphism*).

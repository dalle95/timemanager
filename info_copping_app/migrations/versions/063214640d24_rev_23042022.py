"""rev_23042022

Revision ID: 063214640d24
Revises: 8e4c2cb526b9
Create Date: 2022-04-25 14:12:42.496191

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '063214640d24'
down_revision = '8e4c2cb526b9'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('costo', sa.Column('costo_attivo', sa.Boolean(), nullable=True))
    op.create_index(op.f('ix_costo_costo_attivo'), 'costo', ['costo_attivo'], unique=False)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_costo_costo_attivo'), table_name='costo')
    op.drop_column('costo', 'costo_attivo')
    # ### end Alembic commands ###

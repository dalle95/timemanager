"""inizializzazion

Revision ID: cc1311a04bbb
Revises: 728073645056
Create Date: 2022-03-06 08:26:08.808547

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'cc1311a04bbb'
down_revision = '728073645056'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('bot', sa.Column('scadenza_giorni', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_bot_scadenza_giorni'), 'bot', ['scadenza_giorni'], unique=False)
    op.add_column('item', sa.Column('region', sa.String(length=100), nullable=True))
    op.create_index(op.f('ix_item_region'), 'item', ['region'], unique=False)
    op.add_column('proxy', sa.Column('scadenza_giorni', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_proxy_scadenza_giorni'), 'proxy', ['scadenza_giorni'], unique=False)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_proxy_scadenza_giorni'), table_name='proxy')
    op.drop_column('proxy', 'scadenza_giorni')
    op.drop_index(op.f('ix_item_region'), table_name='item')
    op.drop_column('item', 'region')
    op.drop_index(op.f('ix_bot_scadenza_giorni'), table_name='bot')
    op.drop_column('bot', 'scadenza_giorni')
    # ### end Alembic commands ###
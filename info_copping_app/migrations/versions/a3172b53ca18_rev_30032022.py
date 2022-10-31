"""rev_30032022

Revision ID: a3172b53ca18
Revises: 7afb1b06c717
Create Date: 2022-03-30 18:53:13.026557

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'a3172b53ca18'
down_revision = '7afb1b06c717'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('cliente',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('nome', sa.String(length=100), nullable=True),
    sa.Column('numero_telefono', sa.String(length=100), nullable=True),
    sa.Column('taglia', sa.String(length=100), nullable=True),
    sa.Column('note', sa.String(length=100), nullable=True),
    sa.Column('data_creazione', sa.DateTime(), nullable=True),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['user.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_cliente_data_creazione'), 'cliente', ['data_creazione'], unique=False)
    op.create_index(op.f('ix_cliente_nome'), 'cliente', ['nome'], unique=False)
    op.create_index(op.f('ix_cliente_note'), 'cliente', ['note'], unique=False)
    op.create_index(op.f('ix_cliente_numero_telefono'), 'cliente', ['numero_telefono'], unique=False)
    op.create_index(op.f('ix_cliente_taglia'), 'cliente', ['taglia'], unique=False)
    op.create_table('cliente_contatti',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('cliente_id', sa.Integer(), nullable=True),
    sa.Column('social', sa.String(length=100), nullable=True),
    sa.Column('nome', sa.String(length=100), nullable=True),
    sa.Column('note', sa.String(length=200), nullable=True),
    sa.ForeignKeyConstraint(['cliente_id'], ['cliente.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_cliente_contatti_nome'), 'cliente_contatti', ['nome'], unique=False)
    op.create_index(op.f('ix_cliente_contatti_note'), 'cliente_contatti', ['note'], unique=False)
    op.create_index(op.f('ix_cliente_contatti_social'), 'cliente_contatti', ['social'], unique=False)
    op.add_column('bot', sa.Column('scadenza_giorni', sa.Integer(), nullable=True))
    op.add_column('bot', sa.Column('salva_rinnovo', sa.Boolean(), nullable=True))
    op.create_index(op.f('ix_bot_salva_rinnovo'), 'bot', ['salva_rinnovo'], unique=False)
    op.create_index(op.f('ix_bot_scadenza_giorni'), 'bot', ['scadenza_giorni'], unique=False)
    op.add_column('item', sa.Column('region', sa.String(length=100), nullable=True))
    op.add_column('item', sa.Column('strategia', sa.String(length=100), nullable=True))
    op.create_index(op.f('ix_item_region'), 'item', ['region'], unique=False)
    op.create_index(op.f('ix_item_strategia'), 'item', ['strategia'], unique=False)
    op.add_column('proxy', sa.Column('scadenza_giorni', sa.Integer(), nullable=True))
    op.add_column('proxy', sa.Column('salva_rinnovo', sa.Boolean(), nullable=True))
    op.create_index(op.f('ix_proxy_salva_rinnovo'), 'proxy', ['salva_rinnovo'], unique=False)
    op.create_index(op.f('ix_proxy_scadenza_giorni'), 'proxy', ['scadenza_giorni'], unique=False)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_index(op.f('ix_proxy_scadenza_giorni'), table_name='proxy')
    op.drop_index(op.f('ix_proxy_salva_rinnovo'), table_name='proxy')
    op.drop_column('proxy', 'salva_rinnovo')
    op.drop_column('proxy', 'scadenza_giorni')
    op.drop_index(op.f('ix_item_strategia'), table_name='item')
    op.drop_index(op.f('ix_item_region'), table_name='item')
    op.drop_column('item', 'strategia')
    op.drop_column('item', 'region')
    op.drop_index(op.f('ix_bot_scadenza_giorni'), table_name='bot')
    op.drop_index(op.f('ix_bot_salva_rinnovo'), table_name='bot')
    op.drop_column('bot', 'salva_rinnovo')
    op.drop_column('bot', 'scadenza_giorni')
    op.drop_index(op.f('ix_cliente_contatti_social'), table_name='cliente_contatti')
    op.drop_index(op.f('ix_cliente_contatti_note'), table_name='cliente_contatti')
    op.drop_index(op.f('ix_cliente_contatti_nome'), table_name='cliente_contatti')
    op.drop_table('cliente_contatti')
    op.drop_index(op.f('ix_cliente_taglia'), table_name='cliente')
    op.drop_index(op.f('ix_cliente_numero_telefono'), table_name='cliente')
    op.drop_index(op.f('ix_cliente_note'), table_name='cliente')
    op.drop_index(op.f('ix_cliente_nome'), table_name='cliente')
    op.drop_index(op.f('ix_cliente_data_creazione'), table_name='cliente')
    op.drop_table('cliente')
    # ### end Alembic commands ###
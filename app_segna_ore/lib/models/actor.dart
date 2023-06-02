class Actor {
  String? id;
  String code;
  String nome;
  String? tecnicoID;

  Actor({
    required this.id,
    required this.code,
    required this.nome,
    this.tecnicoID,
  });
}

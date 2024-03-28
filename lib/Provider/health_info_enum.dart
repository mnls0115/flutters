enum Gender { male, female }

extension GenderExtension on Gender {
  String? get getGenderString {
    switch (this) {
      case Gender.male:
        return '남아';
      case Gender.female:
        return '여아';
      default:
        return null;
    }
  }
}

extension GenderString on String {
  Gender? get getStringGender {
    switch (this) {
      case '남아':
        return Gender.male;
      case '여아':
        return Gender.female;
      default:
        return null;
    }
  }
}

enum BloodType { ap, am, bp, bm, op, om, abp, abm }

extension BloodTypeExtension on BloodType {
  String? get getTypeString {
    switch (this) {
      case BloodType.ap:
        return 'A +';
      case BloodType.am:
        return 'A -';
      case BloodType.bp:
        return 'B +';
      case BloodType.bm:
        return 'B -';
      case BloodType.op:
        return 'O +';
      case BloodType.om:
        return 'O -';
      case BloodType.abp:
        return 'AB +';
      case BloodType.abm:
        return 'AB -';
      default:
        return null;
    }
  }
}

extension BloodTypeString on String {
  BloodType? get getStringType {
    switch (this) {
      case 'A +':
        return BloodType.ap;
      case 'A -':
        return BloodType.am;
      case 'B +':
        return BloodType.bp;
      case 'B -':
        return BloodType.bm;
      case 'O +':
        return BloodType.op;
      case 'O -':
        return BloodType.om;
      case 'AB +':
        return BloodType.abp;
      case 'AB -':
        return BloodType.abm;
      default:
        return null;
    }
  }
}

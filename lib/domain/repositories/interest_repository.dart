import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/interest.dart';
import 'package:trao_doi_do_app/domain/entities/params/interests_query.dart';

abstract class InterestRepository {
  Future<Either<Failure, InterestActionResult>> createInterest(int postID);
  Future<Either<Failure, InterestActionResult>> cancelInterest(int postID);
  Future<Either<Failure, InterestsResult>> getInterests(InterestsQuery query);
}

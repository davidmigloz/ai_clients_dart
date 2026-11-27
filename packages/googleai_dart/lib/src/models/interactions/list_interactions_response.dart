import '../copy_with_sentinel.dart';

/// Metadata returned when listing stored Vertex AI interactions.
class InteractionMetadata {
  /// The interaction identifier, when returned.
  final String? id;

  /// Creates interaction metadata.
  const InteractionMetadata({this.id});

  /// Parses interaction metadata.
  factory InteractionMetadata.fromJson(Map<String, dynamic> json) =>
      InteractionMetadata(id: json['id'] as String?);

  /// Converts the metadata to its wire representation.
  Map<String, dynamic> toJson() => {'id': ?id};

  /// Returns a copy with the identifier replaced.
  InteractionMetadata copyWith({Object? id = unsetCopyWithValue}) =>
      InteractionMetadata(
        id: id == unsetCopyWithValue ? this.id : id as String?,
      );
}

/// A page of stored Vertex AI interactions.
class ListInteractionsResponse {
  /// Metadata for the interactions on this page.
  final List<InteractionMetadata>? interactionMetadatas;

  /// Token to request the next page, when another page is available.
  final String? nextPageToken;

  /// Creates a page of interaction metadata.
  const ListInteractionsResponse({
    this.interactionMetadatas,
    this.nextPageToken,
  });

  /// Parses a page of interaction metadata.
  factory ListInteractionsResponse.fromJson(Map<String, dynamic> json) =>
      ListInteractionsResponse(
        interactionMetadatas: (json['interaction_metadatas'] as List<dynamic>?)
            ?.map(
              (entry) =>
                  InteractionMetadata.fromJson(entry as Map<String, dynamic>),
            )
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts this page to its wire representation.
  Map<String, dynamic> toJson() => {
    if (interactionMetadatas != null)
      'interaction_metadatas': [
        for (final metadata in interactionMetadatas!) metadata.toJson(),
      ],
    'next_page_token': ?nextPageToken,
  };

  /// Returns a copy with the supplied fields replaced.
  ListInteractionsResponse copyWith({
    Object? interactionMetadatas = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) => ListInteractionsResponse(
    interactionMetadatas: interactionMetadatas == unsetCopyWithValue
        ? this.interactionMetadatas
        : interactionMetadatas as List<InteractionMetadata>?,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );
}

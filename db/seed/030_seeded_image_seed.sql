INSERT INTO stripedbassfishingtool.seeded_image
    (
        title,
        description,
        image_category,
        image_path,
        alt_text,
        linked_reference_type,
        linked_reference_key,
        source_name,
        attribution_notes
    )
VALUES
    (
        'Threadfin Shad',
        'Reference image for identifying threadfin shad forage.',
        'forage',
        '/images/forage/threadfin-shad.webp',
        'Threadfin shad baitfish reference image',
        'forage-species',
        'Threadfin Shad',
        'Personal image',
        'Use only if you own or have rights to this image.'
    ),
    (
        'Dock Light Night Pattern',
        'Example image showing a dock light area used for night fishing notes.',
        'structure',
        '/images/structure/dock-light-example.webp',
        'Dock light shining over water at night',
        'structure-type',
        'Dock Light',
        'Personal image',
        'Use only if you own or have rights to this image.'
    )
ON CONFLICT (image_path) DO NOTHING;
<?php get_header()?>

<main id="primary" class="site-main">

		<!-- render head slider -->
		<?php get_template_part( 'template-parts/head-slider', get_post_type() ); ?>

		<!-- render features section -->
		<?php get_template_part( 'template-parts/features-section', get_post_type() ); ?>

		<!-- render image gallery -->
		<?php get_template_part( 'template-parts/image-gallery', get_post_type() ); ?>

	</main>

<?php

//customized footer with extra content and styles
get_footer();

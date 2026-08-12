package vn.mevabe.shop.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Cau hinh trang tai lieu API (Swagger UI).
 * Truy cap: http://localhost:8080/api/swagger-ui.html
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI mevabeOpenAPI() {
        final String securitySchemeName = "bearerAuth";
        return new OpenAPI()
                .info(new Info()
                        .title("Me & Be Shop API")
                        .description("API backend cho website ban hang Me & Be (e-commerce + blog)")
                        .version("v0.0.1")
                        .contact(new Contact().name("Mevabe Team")))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName, new SecurityScheme()
                                .name(securitySchemeName)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")));
    }
}

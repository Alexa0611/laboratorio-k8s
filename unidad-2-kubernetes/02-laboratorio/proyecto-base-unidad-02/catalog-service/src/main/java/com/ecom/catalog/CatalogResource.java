package com.ecom.catalog;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/v1/products")
public class CatalogResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public String getProducts() {
        return "{\"status\":\"SUCCESS\", \"service\":\"catalog-service\"}";
    }
}

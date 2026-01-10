# Review Checklist (chromadb)

Extends [REVIEW_CHECKLIST-core.md](../../../shared/openapi-toolkit/references/REVIEW_CHECKLIST-core.md).

## Package-Specific Checks

### Authentication
- [ ] `x-chroma-token` header is used for API key auth
- [ ] Auth is optional (for local instances)

### Multi-Tenant Support
- [ ] Default tenant is `default_tenant`
- [ ] Default database is `default_database`
- [ ] Tenant/database can be overridden per-request

### Embedding Functions
- [ ] `EmbeddingFunction` interface is implemented
- [ ] `Embeddable` sealed class has document/image variants
- [ ] Auto-embedding works in add/update/upsert/query

### Data Loaders
- [ ] `DataLoader` interface is implemented
- [ ] URI-based data loading works

### Collection Operations
- [ ] All CRUD operations work (add, get, query, update, upsert, delete)
- [ ] Include enum filters response fields correctly
- [ ] Where/whereDocument filtering works

### API Compatibility
- [ ] Uses v2 API endpoints (`/api/v2/...`)
- [ ] Hierarchical tenant/database/collection URLs are correct

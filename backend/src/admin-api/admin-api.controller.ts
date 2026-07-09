import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { AiProviderStatus, AppPlatform, MaterialAccessType } from '@prisma/client';
import { AdminApiService } from './admin-api.service';

@ApiTags('admin')
@Controller('admin')
export class AdminApiController {
  constructor(private readonly adminApi: AdminApiService) {}

  @Get('dashboard')
  dashboard() {
    return this.adminApi.dashboard();
  }

  @Get('banks')
  listBanks() {
    return this.adminApi.listBanks();
  }

  @Get('banks/:bankId')
  getBank(@Param('bankId') bankId: string) {
    return this.adminApi.getBank(bankId);
  }

  @Get('banks/:bankId/catalog')
  catalogTree(
    @Param('bankId') bankId: string,
    @Query('subjectId') subjectId?: string,
  ) {
    return this.adminApi.catalogTree(bankId, subjectId);
  }

  @Get('banks/:bankId/catalog-summary')
  catalogSummary(@Param('bankId') bankId: string) {
    return this.adminApi.catalogSummary(bankId);
  }

  @Get('questions')
  listQuestions(
    @Query('bankId') bankId?: string,
    @Query('subjectId') subjectId?: string,
    @Query('catalogId') catalogId?: string,
    @Query('type') type?: string,
    @Query('keyword') keyword?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.adminApi.listQuestions({
      bankId,
      subjectId,
      catalogId,
      type,
      keyword,
      page: Number(page ?? 1),
      pageSize: Number(pageSize ?? 20),
    });
  }

  @Patch('questions/:questionId')
  updateQuestion(
    @Param('questionId') questionId: string,
    @Body()
    body: {
      stemText?: string;
      stemHtml?: string;
      analysisText?: string;
      analysisHtml?: string;
      answer?: unknown;
      options?: unknown;
    },
  ) {
    return this.adminApi.updateQuestion(questionId, body);
  }

  @Get('users')
  listUsers() {
    return this.adminApi.listUsers();
  }

  @Get('users/:userId')
  getUser(@Param('userId') userId: string) {
    return this.adminApi.getUser(userId);
  }

  @Get('materials')
  listMaterials(@Query('bankId') bankId?: string) {
    return this.adminApi.listMaterials(bankId);
  }

  @Post('materials')
  createMaterial(
    @Body()
    body: {
      bankId: string;
      title: string;
      subjectName?: string;
      description?: string;
      accessType?: MaterialAccessType;
      coverUrl?: string;
      fileUrl?: string;
      fileType?: string;
      previewMeta?: unknown;
      sortOrder?: number;
    },
  ) {
    return this.adminApi.createMaterial(body);
  }

  @Patch('materials/:id')
  updateMaterial(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      title: string;
      subjectName: string;
      description: string;
      accessType: MaterialAccessType;
      coverUrl: string;
      fileUrl: string;
      fileType: string;
      previewMeta: unknown;
      sortOrder: number;
    }>,
  ) {
    return this.adminApi.updateMaterial(id, body);
  }

  @Delete('materials/:id')
  deleteMaterial(@Param('id') id: string) {
    return this.adminApi.deleteMaterial(id);
  }

  @Get('feedback')
  listFeedback(@Query('status') status?: string) {
    return this.adminApi.listFeedback(status);
  }

  @Post('feedback')
  createFeedback(
    @Body()
    body: {
      userId?: string;
      appKey?: string;
      questionId?: string;
      type: string;
      content: string;
      contact?: string;
    },
  ) {
    return this.adminApi.createFeedback(body);
  }

  @Patch('feedback/:id')
  updateFeedback(@Param('id') id: string, @Body('status') status: string) {
    return this.adminApi.updateFeedback(id, status);
  }

  @Get('ai-models')
  listAiModels() {
    return this.adminApi.listAiModels();
  }

  @Post('ai-models')
  createAiModel(
    @Body()
    body: {
      name: string;
      provider: string;
      model: string;
      endpoint?: string;
      apiKeyAlias?: string;
      status?: AiProviderStatus;
      config?: unknown;
    },
  ) {
    return this.adminApi.createAiModel(body);
  }

  @Patch('ai-models/:id')
  updateAiModel(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      name: string;
      provider: string;
      model: string;
      endpoint: string;
      apiKeyAlias: string;
      status: AiProviderStatus;
      config: unknown;
    }>,
  ) {
    return this.adminApi.updateAiModel(id, body);
  }

  @Delete('ai-models/:id')
  deleteAiModel(@Param('id') id: string) {
    return this.adminApi.deleteAiModel(id);
  }

  @Get('apps')
  listApps() {
    return this.adminApi.listApps();
  }

  @Post('apps')
  upsertApp(
    @Body()
    body: {
      appKey: string;
      name: string;
      platform: AppPlatform;
      packageName?: string;
      bankId: string;
    },
  ) {
    return this.adminApi.upsertApp(body);
  }
}
